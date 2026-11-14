#!/usr/bin/env python3
"""Measure sequential HTML requests; not a browser or concurrent load test."""

import argparse
import csv
import json
import math
from pathlib import Path
import platform
import statistics
import time
from datetime import datetime, timezone
import urllib.error
import urllib.parse
import urllib.request


def request_once(url, timeout):
    started = time.perf_counter()
    status = 0
    error = ""
    try:
        request = urllib.request.Request(
            url,
            headers={
                "User-Agent": "wordpress-aks-measurement/1.0",
                "Accept-Encoding": "identity",
            },
        )
        with urllib.request.urlopen(request, timeout=timeout) as response:
            status = response.status
            response.read()
    except urllib.error.HTTPError as exception:
        status = exception.code
        error = type(exception).__name__
        exception.close()
    except (urllib.error.URLError, TimeoutError, OSError) as exception:
        error = type(exception).__name__
    elapsed_ms = (time.perf_counter() - started) * 1000
    successful = 200 <= status < 300 and not error
    return status, elapsed_ms, successful, error


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", required=True)
    parser.add_argument("--label", required=True)
    parser.add_argument("--output-prefix", required=True)
    parser.add_argument("--samples", type=int, default=30)
    parser.add_argument("--warmups", type=int, default=3)
    parser.add_argument("--pause", type=float, default=0.2)
    parser.add_argument("--timeout", type=float, default=10)
    args = parser.parse_args()

    url = urllib.parse.urlsplit(args.url)
    if url.scheme not in {"http", "https"} or not url.hostname:
        parser.error("Supply an HTTP or HTTPS URL.")
    if url.username or url.password or url.query or url.fragment:
        parser.error("Use a public page URL without credentials, query, or fragment.")
    if args.samples < 1 or args.warmups < 0 or args.pause < 0 or args.timeout <= 0:
        parser.error("Invalid sample count, warmup count, pause, or timeout.")

    started_at = datetime.now(timezone.utc).isoformat()
    print(f"Running {args.warmups} warmups and {args.samples} measured requests.")
    for _ in range(args.warmups):
        request_once(args.url, args.timeout)
        time.sleep(args.pause)

    prefix = Path(args.output_prefix)
    prefix.parent.mkdir(parents=True, exist_ok=True)
    csv_path = Path(str(prefix) + ".csv")
    json_path = Path(str(prefix) + ".json")
    successful_times = []
    failures = 0

    with csv_path.open("w", newline="", encoding="utf-8") as target:
        writer = csv.writer(target)
        writer.writerow(["sample", "http_status", "elapsed_ms", "successful", "error"])
        for sample in range(1, args.samples + 1):
            status, elapsed, successful, error = request_once(args.url, args.timeout)
            writer.writerow([sample, status, round(elapsed, 3), successful, error])
            target.flush()
            if successful:
                successful_times.append(elapsed)
            else:
                failures += 1
            if sample < args.samples:
                time.sleep(args.pause)

    ordered = sorted(successful_times)
    summary = {
        "label": args.label,
        "url": args.url,
        "started_at_utc": started_at,
        "finished_at_utc": datetime.now(timezone.utc).isoformat(),
        "client_platform": platform.platform(),
        "samples": args.samples,
        "warmup_requests": args.warmups,
        "concurrency": 1,
        "pause_seconds": args.pause,
        "socket_timeout_seconds": args.timeout,
        "successes": len(ordered),
        "failures": failures,
        "error_rate_percent": round(100 * failures / args.samples, 2),
        "latency_scope": "Successful final 2xx responses, including full HTML body; redirects followed.",
        "mean_ms": round(statistics.mean(ordered), 3) if ordered else None,
        "median_ms": round(statistics.median(ordered), 3) if ordered else None,
        "p95_ms": round(ordered[math.ceil(len(ordered) * 0.95) - 1], 3) if ordered else None,
        "min_ms": round(ordered[0], 3) if ordered else None,
        "max_ms": round(ordered[-1], 3) if ordered else None,
        "limitations": [
            "Small sequential sample; no concurrent load or capacity measurement.",
            "Does not fetch images, JavaScript, or CSS or measure browser rendering.",
            "Public-network latency and cache state affect results.",
            "p95 uses nearest rank over successful requests only; failures are reported separately.",
        ],
    }
    json_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, indent=2))
    print(f"Saved {csv_path} and {json_path}")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
