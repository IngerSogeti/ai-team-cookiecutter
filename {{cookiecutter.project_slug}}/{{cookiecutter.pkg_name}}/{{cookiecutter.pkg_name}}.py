"""Main module."""


def hello() -> str:
    """Return who to say hello to."""
    return "world!"


if __name__ == "__main__":
    print(f"Hello {hello()}")
