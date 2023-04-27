import pandas as pd
import asyncio
import aiohttp


def name_match(merged, sci_name):
    # Name matching records with API
    api_link = "https://namematching-ws.ala.org.au/api/searchByClassification"

    # Function that sends individual get request
    async def submit_request(session, name):
        async with session.get(api_link, params={'scientificName': name}) as req:
            return name, await req.json()

    # Creates a list of tasks then executes all simultaneously
    async def submit_all_requests(session, name_list):
        tasks = []
        for name in name_list:
            task = asyncio.create_task(submit_request(session, name))
            tasks.append(task)
        res = await asyncio.gather(*tasks)
        return res

    # Sends the species names to be submitted to the API
    async def send_names():
        name_list = merged[sci_name].tolist()

        async with aiohttp.ClientSession() as session:
            data = await submit_all_requests(session, name_list)
            return data

    # Command that executes and receives data from async calls
    api_data = asyncio.run(send_names())

    matched_list = pd.DataFrame()
    exact_matches = []
    canon_match = []
    insufficient_level = []     # Not down to species or subspecies level
    not_found = []             # Species not in the ALA taxonomy

    # Sorting out species by quality of name match
    for item in api_data:
        sp_name, sp_info = item

        if sp_info['success']:
            if sp_info['matchType'] == 'exactMatch':
                if sp_info['rank'] in ['species', 'subspecies']:
                    if 'family' in sp_info:
                        exact_matches.append(sp_info['scientificName'])
                        data_df = pd.DataFrame({"species": [sp_name], "updated_name": [sp_info['scientificName']]})
                        matched_list = pd.concat([matched_list, data_df])
                else:
                    insufficient_level.append(sp_name)
            else:
                canon_match.append(sp_info['scientificName'])
        else:
            not_found.append(sp_name)

    # Filtering invalid records from merged GeoDataFrame
    if len(merged) != len(exact_matches):
        valid_records = merged[merged[sci_name].isin(exact_matches)].reset_index(drop=True)
        invalid_records = merged[~merged[sci_name].isin(exact_matches)].reset_index(drop=True)

        # Printing out details about removed records
        print(f'{len(invalid_records)} low quality record(s) removed.')
        print(f'{len(not_found)} species not found in the ALA:')
        print(not_found)
        print(f'{len(canon_match)} species changed taxon:')
        print(canon_match)
        print(f'{len(insufficient_level)} record(s) not down to species or subspecies level:')
        print(insufficient_level)

    else:
        valid_records = merged
        print(f'All {len(merged)} records are valid.')

    return matched_list


eucs_data = pd.read_csv('/Users/elijah/Library/CloudStorage/OneDrive-UNSW/Honours/Aus_only_eucs.csv')

new_names = name_match(eucs_data, 'Species')
new_names['Genus'] = new_names['updated_name'].str.split(" ", n=1, expand=True)[0]
print(new_names['Genus'].unique())
