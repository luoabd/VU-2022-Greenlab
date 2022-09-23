# VU-2022-Greenlab (App vs. Web)
VU Green Lab replication package for [our report](https://www.overleaf.com/read/jcwgrxgxtrnb).

## Utilities
Use `utils/generate_candidate_subjects.py` to find candidate subjects from the Tranco and Google Play lists.  
Use `utils/apps.sh` to (un)install the APKs for all subjects from this folder.  
The file `apks/summary.txt` contains information about the apps used and was generated using `utils/generate_summary.sh`.

## Experiment
The experiment can be run using the [android-runner](https://github.com/S2-group/android-runner) with `python3 <path to android-runner> experiments/<the experiment>/config.json`.

**TODO** Replace example experiment with own
