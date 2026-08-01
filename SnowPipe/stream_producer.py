import time
import random
from datetime import datetime
from snowflake.ingest.streaming import StreamingIngestClient

# -------------------------------------------------------------
# CONFIGURATION
# -------------------------------------------------------------
ACCOUNT = "NHWDNTX-SXB19671"   # Full Account Identifier (Org-Account)
USER = "DATA2DOLLARS"          # Username
ROLE = "ACCOUNTADMIN"          # Role
DATABASE = "DEMO_DB"
SCHEMA = "PUBLIC"
TABLE = "SENSOR_READINGS"
PRIVATE_KEY_PATH = "rsa_key.p8"

# 1. Read Private Key File
with open(PRIVATE_KEY_PATH, "rb") as f:
    private_key_pem = f.read().decode("utf-8")

# 2. Connection Properties Dictionary
client_config = {
    "account": ACCOUNT,
    "user": USER,
    "role": ROLE,
    "private_key": private_key_pem,
    "url": "https://nhwdntx-sxb19671.snowflakecomputing.com:443"
}

print("🔌 Connecting to Snowflake Snowpipe Streaming...")

# 3. Instantiate Client using `from_table`
client = StreamingIngestClient.from_table(
    client_name="YT_Demo_Client",
    db_name=DATABASE,
    schema_name=SCHEMA,
    table_name=TABLE,
    properties=client_config
)

# 4. Open Ingestion Channel
channel, status = client.open_channel(channel_name="IoT_Channel_1")

print("🚀 Connected! Streaming live sensor records to Snowflake...")

try:
    # 5. Stream 15 mock records, 1 per second
    for offset in range(1, 16):
        payload = {
            "DEVICE_ID": f"SENSOR_{random.randint(101, 105)}",
            "TEMPERATURE": round(random.uniform(18.0, 32.0), 2),
            "HUMIDITY": round(random.uniform(45.0, 75.0), 2),
            "READING_TIME": datetime.utcnow().isoformat()
        }

        # --- FIX: Use standard channel insertion methods ---
        if hasattr(channel, "insert_rows"):
            channel.insert_rows([payload], str(offset))
        elif hasattr(channel, "insert_row"):
            channel.insert_row(payload, str(offset))
        else:
            # Direct Rust object method fallback
            channel.append_rows([payload], str(offset))
        
        print(f"Sent Row {offset}: {payload['DEVICE_ID']} | Temp: {payload['TEMPERATURE']}°C")
        
        time.sleep(1)

    print("✅ Finished streaming batch successfully.")

finally:
    # 6. Graceful cleanup
    channel.close()
    client.close()
    print("🔒 Connection closed cleanly.")
