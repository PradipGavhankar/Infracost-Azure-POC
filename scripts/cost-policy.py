#!/usr/bin/env python3
\"\"\"Fail closed if Infracost JSON cannot be interpreted or cost exceeds cap.

The Infracost JSON schema can evolve. This parser intentionally accepts the
common project-level totalMonthlyCost field and refuses unknown structures
rather than silently approving a deployment.
\"\"\"
import argparse
import json
import sys
from decimal import Decimal, InvalidOperation
from pathlib import Path

def get_total(data):
    projects = data.get("projects")
    if not isinstance(projects, list) or not projects:
        raise ValueError("No projects[] found in Infracost JSON")
    totals = []
    for project in projects:
        value = project.get("totalMonthlyCost")
        if value is None:
            summary = project.get("summary") or {}
            value = summary.get("totalMonthlyCost")
        if value is None:
            raise ValueError("Missing project totalMonthlyCost; inspect CLI JSON schema")
        totals.append(Decimal(str(value)))
    return sum(totals, Decimal("0"))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--policy", required=True)
    args = parser.parse_args()

    try:
        data = json.loads(Path(args.input).read_text())
        policy = json.loads(Path(args.policy).read_text())
        total = get_total(data)
        cap = Decimal(str(policy["max_monthly_cost"]))
        currency = policy.get("currency", "USD")
        print(f"Estimated monthly cost: {currency} {total}")
        print(f"Configured monthly cap: {currency} {cap}")
        if total > cap:
            print("FAIL: monthly cost exceeds configured cap.", file=sys.stderr)
            return 1
        print("PASS: monthly cost is within configured cap.")
        return 0
    except (OSError, json.JSONDecodeError, KeyError, ValueError, InvalidOperation) as exc:
        print(f"FAIL CLOSED: cost policy could not be evaluated: {exc}", file=sys.stderr)
        return 2

if __name__ == "__main__":
    sys.exit(main())
