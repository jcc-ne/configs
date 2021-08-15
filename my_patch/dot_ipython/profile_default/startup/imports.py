import os
import sys
import pickle
import datetime as dt
import numpy as np
import pandas as pd
import _add_sandbox_paths
import asyncio
import time


def import_plt():
    import matplotlib
    try:
        # matplotlib.use('MacOSX')
        matplotlib.use('Qt5Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        # matplotlib.use('TkAgg')
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    return plt
