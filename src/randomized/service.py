import random
from randomized.schemas import RandomIntsList

class RandomNumbers:

    def get_random_numbers(self, min: int = 0, max: int = 100, count: int = 1) -> RandomIntsList:
        _values: list[int] = random.sample(range(min, max), count)
        return RandomIntsList(min=min, max=max, count=count, values=_values)
