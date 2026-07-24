# sample.py — visual eyeball buffer.
# Use `python-ts-mode' with `treesit-font-lock-level' = 4.

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class Rectangle:
    """A simple rectangle, doubling as a syntax-coverage sample."""

    width: int = 1
    height: int = 1

    @property
    def area(self) -> int:
        return self.width * self.height

    def scale(self, factor: float) -> "Rectangle":
        return Rectangle(int(self.width * factor), int(self.height * factor))


def total_area(rects: Iterable[Rectangle]) -> int:
    # Comprehensions, builtins, numbers, operators, f-strings:
    return sum(r.area for r in rects if r.area > 0)


if __name__ == "__main__":
    rects = [Rectangle(15, 7), Rectangle().scale(2.5)]
    for i, r in enumerate(rects, start=1):
        print(f"#{i}: {r.width}x{r.height} = {r.area}")
    print(f"total = {total_area(rects)}")
