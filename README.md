# VU-2022-Greenlab (App vs. Web)
VU Green Lab replication package for [our report](https://www.overleaf.com/read/jcwgrxgxtrnb).

**Note!** The scripts require `bash` to be the default shell of the user.

## Utilities
**Note!** All scripts are intended for use with only a single device connected over ADB.

The file `utils/Candidate_subjects.csv` was generated using `utils/generate_candidate_subjects.py` and the Tranco and Google Play lists.  
From this, the 10 subjects were manually selected.  
The file `apks/summary.txt` contains information about the native versions of the subjects and was generated using `utils/generate_summary.sh`.
Use `utils/apps.sh` to (un)install the APKs for all subjects from this folder.  
The script `utils/pre_run.sh` ensures that all experiments are conducted using a consistent device state. (Append `clear` to delete all app data.)
Use `utils/tap_text.sh` to click on a UI element with text matching a given pattern through ADB.
Use `utils/clear_cache.sh` to clear the cache (but not the data) of an application.
Use `utils/current_app.sh` and `utils/current_url.sh` to query the currently running native or web app respectively over ADB.

## Experiment
The experiment can be run using the [android-runner](https://github.com/S2-group/android-runner) with `python3 <path to android-runner> experiments/<the experiment>/config.json`.

**TODO** Replace example experiment with own
