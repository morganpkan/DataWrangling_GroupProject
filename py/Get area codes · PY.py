
"""
Batch-query the Koordinates Query API to find the Statistical Area 2 (SA2)
that each Airbnb listing's lat/long falls within.
 
Before running the full batch:
  1. Run test_single_query() below and confirm the field names in the
     response match SA2_CODE_FIELD / SA2_NAME_FIELD.
  2. Adjust INPUT_CSV / OUTPUT_CSV / column names to match your data.
  3. Start with a small NUM_WORKERS and watch for HTTP 429 (rate limit)
     errors before scaling up.
"""
 
import time
import requests
import pandas as pd
from multiprocessing import Pool
 
# ---- Configuration ----------------------------------------------------
API_KEY = "###"          # <-- put your Koordinates API key here
LAYER_ID = "###"               # Statistical Area 2 2026
BASE_URL = "###"
 
# Field names on the SA2 layer — confirm these from your test query response
SA2_CODE_FIELD = "SA22026_V1_00"
SA2_NAME_FIELD = "SA22026_V1_00_NAME"
 
INPUT_CSV = "airbnb_data.csv"     # must contain listing_id, latitude, longitude
OUTPUT_CSV = "airbnb_area_codes.csv"
 
NUM_WORKERS = 8                    # tune down if you hit rate limits (HTTP 429)
RADIUS_METERS = 100
REQUEST_TIMEOUT = 10
MAX_RETRIES = 3
RETRY_BACKOFF_SECONDS = 2
# ------------------------------------------------------------------------
 
 
def test_single_query(lat: float, lon: float):
    """Run this manually first on one known lat/long to sanity-check the
    layer ID, field names, and API key before batch processing."""
    params = {
        "key": API_KEY,
        "layer": LAYER_ID,
        "x": lon,
        "y": lat,
        "max_results": 1,
        "radius": RADIUS_METERS,
        "geometry": "false",
        "with_field_names": "true",
    }
    resp = requests.get(BASE_URL, params=params, timeout=REQUEST_TIMEOUT)
    resp.raise_for_status()
    data = resp.json()
    print(data)  # inspect this to confirm field names
    return data
 
 
def query_area_code(row):
    """Worker function: given (listing_id, lat, lon), return
    (listing_id, sa2_code, sa2_name) or (listing_id, None, None) on failure."""
    listing_id, lat, lon = row
 
    params = {
        "key": API_KEY,
        "layer": LAYER_ID,
        "x": lon,
        "y": lat,
        "max_results": 1,
        "radius": RADIUS_METERS,
        "geometry": "false",
        "with_field_names": "true",
    }
 
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = requests.get(BASE_URL, params=params, timeout=REQUEST_TIMEOUT)
 
            if resp.status_code == 429:
                # Rate limited — back off and retry
                time.sleep(RETRY_BACKOFF_SECONDS * attempt)
                continue
 
            resp.raise_for_status()
            data = resp.json()
 
            features = (
                data.get("vectorQuery", {})
                .get("layers", {})
                .get(str(LAYER_ID), {})
                .get("features", [])
            )
 
            if features:
                props = features[0]["properties"]
                sa2_code = props.get(SA2_CODE_FIELD)
                sa2_name = props.get(SA2_NAME_FIELD)
                return (listing_id, sa2_code, sa2_name)
            else:
                # No match found within radius — point may be outside NZ
                # or radius too small
                return (listing_id, None, None)
 
        except requests.exceptions.RequestException as e:
            if attempt == MAX_RETRIES:
                print(f"Failed listing {listing_id} after {MAX_RETRIES} attempts: {e}")
                return (listing_id, None, None)
            time.sleep(RETRY_BACKOFF_SECONDS * attempt)
 
    return (listing_id, None, None)
 
 
def main():
    df = pd.read_csv(INPUT_CSV)
    df["id"] = df["id"].astype("Int64")
 
    # Adjust these column names to match your cleaned Airbnb CSV
    rows = list(
        df[["id", "latitude", "longitude"]].itertuples(index=False, name=None)
    )
    rows = [(lid, lat, lon) for (lid, lat, lon) in rows]
 
    print(f"Querying {len(rows)} listings with {NUM_WORKERS} workers...")
 
    with Pool(processes=NUM_WORKERS) as pool:
        results = pool.map(query_area_code, rows)
 
    result_df = pd.DataFrame(results, columns=["listing_id", "sa2_code", "sa2_name"])
 
    n_missing = result_df["sa2_code"].isna().sum()
    print(f"Done. {n_missing} of {len(result_df)} listings had no match.")
 
    result_df.to_csv(OUTPUT_CSV, index=False)
    print(f"Saved results to {OUTPUT_CSV}")
 
 
if __name__ == "__main__":
    # Uncomment to test a single query first:
    #test_single_query(lat=, lon=)
 
    main()  
