#! /usr/bin/python3

import random
import pandas as pd
import re
from pathlib import Path

SEED = 420

# TODO: add comments
# TODO: change paths


def find_first(name):
    domains = web_df['name'].to_list()
    for i in range(len(domains)):
        domain = domains[i]
        if domain.split('.')[0] == name:
            return (i+1, domain)
    return (-1, None)


app_df = pd.read_csv('/home/luoabd/Downloads/Google-Playstore.csv')
processed_app_df = app_df.sort_values(by=["Minimum Installs"], ascending=False)
processed_app_df = processed_app_df.head(2000)

web_df = pd.read_csv('/home/luoabd/Downloads/tranco_5Y7PN.csv',
                     nrows=2000, names=["ID", "name"])

processed_app_df['App Name'] = processed_app_df['App Name'].str.lower()
processed_app_df['App Name'] = processed_app_df['App Name'].apply(
    lambda s: re.sub(r"[^0-9a-z\s]", '', s))

web_df['base_name'] = web_df['name'].str.extract(
    '(^[^.][^.]+)', expand=False).str.strip()
web_list = web_df['base_name'].astype(str).to_list()
app_list = processed_app_df['App Name'].astype(str).to_list()
app_list = [re.sub("\s\s.*", "", s) for s in app_list]


cross_list = []

for site in web_list:
    for app in app_list:
        if site in app.split(' '):
            cross_list.append(site)
            break

final_csv = pd.DataFrame(cross_list, columns=[
                         'name']).drop_duplicates().astype(str)
page_rank = final_csv['name'].apply(lambda s: find_first(s)[0])
page_domain = final_csv['name'].apply(lambda s: find_first(s)[1])

random.seed(SEED)
perm = list(range(len(final_csv)))
random.shuffle(perm)


output_name = str((Path(__file__).parent / f'Candidate_subjects.csv').absolute())
pd.DataFrame(data={'Rank': page_rank, 'Domain': page_domain, 'Sampling index': perm}).sort_values(
    'Sampling index').to_csv(output_name, index=False)
