"""Vybere testy k spusteni podle obsahu test runu v TestRailu.

Prectete testy v zadanem runu (API get_tests), u kazdeho vezme automation_id jeho casu
a zapise je do argument filu pro Robot Framework jako --test filtry. Robot pak spusti
jen testy, ktere nekdo vybral do runu v TestRailu (cely run, suite, sekce nebo jednotlive casy).

Prihlaseni: promenne prostredi TESTRAIL_HOST, TESTRAIL_USER, TESTRAIL_API_KEY.

Pouziti:
    python tools/select-tests.py --run-id 4
    robot --argumentfile results/selected-tests.args --outputdir results tests
"""
import argparse
import os
import sys

import requests


def api_get(session, host, endpoint):
    url = f"{host.rstrip('/')}/index.php?/api/v2/{endpoint}"
    response = session.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


def get_all_tests(session, host, run_id):
    """Vrati vsechny testy runu (API je strankovane po 250 polozkach)."""
    tests, offset = [], 0
    while True:
        data = api_get(session, host, f"get_tests/{run_id}&limit=250&offset={offset}")
        page = data.get("tests", data) if isinstance(data, dict) else data
        tests.extend(page)
        if not isinstance(data, dict) or not (data.get("_links") or {}).get("next"):
            return tests
        offset += len(page)


def find_automation_id(item):
    for key, value in item.items():
        if key.endswith("automation_id") and value:
            return str(value).strip()
    return None


def escape_pattern(name):
    """Robot bere --test jako vzor (* ? [ ]), proto specialni znaky zneskodnime."""
    return "".join(f"[{ch}]" if ch in "*?[]" else ch for ch in name)


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(errors="replace")
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--run-id", required=True, type=int)
    parser.add_argument("--root-suite", default="Tests",
                        help="spoustet jen casy, jejichz automation_id zacina timto nazvem suite")
    parser.add_argument("--out", default=os.path.join("results", "selected-tests.args"))
    args = parser.parse_args()

    host = os.environ.get("TESTRAIL_HOST", "https://vojta1trial.testrail.io")
    user, key = os.environ.get("TESTRAIL_USER"), os.environ.get("TESTRAIL_API_KEY")
    if not user or not key:
        sys.exit("Chybi promenne prostredi TESTRAIL_USER nebo TESTRAIL_API_KEY.")

    session = requests.Session()
    session.auth = (user, key)
    session.headers["Content-Type"] = "application/json"

    tests = get_all_tests(session, host, args.run_id)
    print(f"Run R{args.run_id} obsahuje {len(tests)} testu.")

    selected, skipped = [], []
    for test in tests:
        automation_id = find_automation_id(test)
        if not automation_id:
            case = api_get(session, host, f"get_case/{test['case_id']}")
            automation_id = find_automation_id(case)
        label = f"T{test['id']} (C{test['case_id']}) {test.get('title', '')}"
        if not automation_id:
            skipped.append(f"{label}: chybi automation_id (manualni test?)")
        elif not automation_id.startswith(args.root_suite + "."):
            skipped.append(f"{label}: patri jine sade ({automation_id.split('.')[0]})")
        else:
            selected.append(automation_id)
            print(f"  + {label}")

    for reason in skipped:
        print(f"  - preskoceno: {reason}")

    if not selected:
        sys.exit("V runu neni zadny automatizovany test pro tuto sadu, neni co spustit.")

    os.makedirs(os.path.dirname(args.out) or ".", exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as handle:
        for automation_id in sorted(set(selected)):
            handle.write(f"--test {escape_pattern(automation_id)}\n")
    print(f"Vybrano {len(set(selected))} testu, filtr ulozen do {args.out}")


if __name__ == "__main__":
    main()
