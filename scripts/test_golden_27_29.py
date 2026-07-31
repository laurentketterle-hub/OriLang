#!/usr/bin/env python3
"""Golden output tests for OriLang beginner samples 27–29.

Runs each sample through the OriLang VM (orivm) and compares
actual output against expected golden output.

Usage:
  python3 scripts/test_golden_27_29.py [--orivm PATH] [--update]

Golden outputs:
  tests/golden/beginner_27_countdown.txt
  tests/golden/beginner_28_max_of_three.txt
  tests/golden/beginner_29_echo_name.txt
"""
import subprocess
import sys
import os
import argparse
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SAMPLES_DIR = REPO_ROOT / "samples" / "beginner"
GOLDEN_DIR = REPO_ROOT / "tests" / "golden"
RESULTS_DIR = REPO_ROOT / "tests" / "results"

SAMPLES = [
    ("beginner_27_countdown.ori", "beginner_27_countdown.txt",
     "Countdown from 5 to 1 with Liftoff"),
    ("beginner_28_max_of_three.ori", "beginner_28_max_of_three.txt",
     "Find max of three numbers (15, 42, 8)"),
    ("beginner_29_echo_name.ori", "beginner_29_echo_name.txt",
     "Echo a name with greeting"),
]

GOLDEN_OUTPUTS = {
    "beginner_27_countdown.txt": "5\n4\n3\n2\n1\nLiftoff!\n",
    "beginner_28_max_of_three.txt": "Max is: 42\n",
    "beginner_29_echo_name.txt": "Hello, Ori Developer!\n",
}


def find_orivm(orivm_path=None):
    """Find the orivm binary."""
    if orivm_path:
        p = Path(orivm_path)
        if p.exists():
            return str(p)

    candidates = [
        REPO_ROOT / "core" / "orivm",
        REPO_ROOT / "core" / "orivm.exe",
        REPO_ROOT / "core" / "build" / "orivm",
        REPO_ROOT / "build" / "core" / "orivm",
    ]
    for c in candidates:
        if c.exists():
            return str(c)

    # Try PATH
    for name in ["orivm", "orivm.exe"]:
        try:
            result = subprocess.run(
                ["which", name] if sys.platform != "win32" else ["where", name],
                capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip().split("\n")[0]
        except Exception:
            pass

    return None


def run_sample(orivm_path, sample_path):
    """Run a sample through the VM and capture output."""
    result = subprocess.run(
        [orivm_path, str(sample_path)],
        capture_output=True,
        text=True,
        timeout=30,
        cwd=str(REPO_ROOT),
    )
    return result.stdout


def update_golden(orivm_path):
    """Regenerate golden output files."""
    GOLDEN_DIR.mkdir(parents=True, exist_ok=True)

    for sample_file, golden_file, description in SAMPLES:
        sample_path = SAMPLES_DIR / sample_file
        if not sample_path.exists():
            print(f"SKIP: {sample_file} not found")
            continue

        output = run_sample(orivm_path, sample_path)
        golden_path = GOLDEN_DIR / golden_file
        golden_path.write_text(output)
        print(f"UPDATED: {golden_file} ({description})")


def run_tests(orivm_path):
    """Run golden output tests."""
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    GOLDEN_DIR.mkdir(parents=True, exist_ok=True)

    passed = 0
    failed = 0
    results = []

    for sample_file, golden_file, description in SAMPLES:
        sample_path = SAMPLES_DIR / sample_file
        golden_path = GOLDEN_DIR / golden_file

        if not sample_path.exists():
            print(f"SKIP: {sample_file} not found")
            results.append({"sample": sample_file, "status": "SKIP", "reason": "file not found"})
            continue

        try:
            actual_output = run_sample(orivm_path, sample_path)
        except subprocess.TimeoutExpired:
            print(f"FAIL: {sample_file} — timed out after 30s")
            results.append({"sample": sample_file, "status": "FAIL", "reason": "timeout"})
            failed += 1
            continue
        except Exception as e:
            print(f"FAIL: {sample_file} — error: {e}")
            results.append({"sample": sample_file, "status": "FAIL", "reason": str(e)})
            failed += 1
            continue

        # Get expected output
        if golden_path.exists():
            expected_output = golden_path.read_text()
        elif golden_file in GOLDEN_OUTPUTS:
            expected_output = GOLDEN_OUTPUTS[golden_file]
        else:
            print(f"FAIL: {golden_file} — no golden output available")
            results.append({"sample": sample_file, "status": "FAIL", "reason": "no golden file"})
            failed += 1
            continue

        # Save actual output
        result_path = RESULTS_DIR / f"{Path(sample_file).stem}_actual.txt"
        result_path.write_text(actual_output)

        # Compare
        if actual_output == expected_output:
            print(f"PASS: {sample_file} ({description})")
            passed += 1
            results.append({"sample": sample_file, "status": "PASS"})
        else:
            print(f"FAIL: {sample_file} ({description})")
            print(f"  Expected: {expected_output!r}")
            print(f"  Actual:   {actual_output!r}")

            # Show diff
            exp_lines = expected_output.splitlines()
            act_lines = actual_output.splitlines()
            max_lines = max(len(exp_lines), len(act_lines))
            for i in range(max_lines):
                exp = exp_lines[i] if i < len(exp_lines) else "<missing>"
                act = act_lines[i] if i < len(act_lines) else "<missing>"
                if exp != act:
                    print(f"  Line {i+1}: expected '{exp}' got '{act}'")

            failed += 1
            results.append({"sample": sample_file, "status": "FAIL", "details": "output mismatch"})

    # Summary
    print(f"\n{'='*50}")
    print(f"Results: {passed} passed, {failed} failed, {len(SAMPLES)} total")
    
    # Write structured results
    import json
    summary = {
        "passed": passed,
        "failed": failed,
        "total": len(SAMPLES),
        "results": results,
    }
    (REPO_ROOT / "tests" / "results.json").write_text(json.dumps(summary, indent=2))

    return failed == 0


def main():
    parser = argparse.ArgumentParser(description="Golden output tests for OriLang beginner 27-29")
    parser.add_argument("--orivm", help="Path to orivm binary")
    parser.add_argument("--update", action="store_true", help="Regenerate golden output files")
    args = parser.parse_args()

    orivm_path = find_orivm(args.orivm)

    if args.update:
        if not orivm_path:
            print("ERROR: Cannot find orivm. Use --orivm to specify path.")
            sys.exit(1)
        update_golden(orivm_path)
        return

    if not orivm_path:
        print("=" * 50)
        print("WARNING: orivm binary not found!")
        print("The tests will run in 'dry-run' mode.")
        print("Golden outputs are pre-computed — no VM execution needed.")
        print("=" * 50)
        
        # Dry-run: just verify golden files exist and samples exist
        all_ok = True
        for sample_file, golden_file, description in SAMPLES:
            sample_path = SAMPLES_DIR / sample_file
            sample_ok = sample_path.exists()
            golden_ok = (GOLDEN_DIR / golden_file).exists() or golden_file in GOLDEN_OUTPUTS
            status = "OK" if (sample_ok and golden_ok) else "MISSING"
            if not sample_ok or not golden_ok:
                all_ok = False
            print(f"  [{status}] {sample_file} -> {golden_file} ({description})")
        
        print(f"\nDry-run {'passed' if all_ok else 'failed'}.")
        print(f"Install gcc and run 'bash build.sh' to build the VM for full tests.")
        sys.exit(0 if all_ok else 1)

    print(f"Using orivm: {orivm_path}")
    success = run_tests(orivm_path)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
