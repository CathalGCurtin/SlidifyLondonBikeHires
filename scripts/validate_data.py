"""Verify that the historical source is byte-for-byte unchanged."""
from hashlib import sha256
from pathlib import Path

expected = "a650332b0ea18405f351cca63ccd6ee51534474ba3b80ac20e077a65a3c106a3"
actual = sha256(Path("tfl-daily-cycle-hires.csv").read_bytes()).hexdigest()
if actual != expected:
    raise SystemExit(f"Historical CSV changed: {actual}")
print("Historical CSV SHA-256 matches the original.")
