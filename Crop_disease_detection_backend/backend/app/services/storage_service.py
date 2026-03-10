import psycopg2
from config import DB_CONFIG

def update_result(media_id, disease):
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    cur.execute("""
        UPDATE media
        SET status = 'COMPLETED',
            result = %s
        WHERE id = %s
    """, (disease, media_id))

    conn.commit()
    cur.close()
    conn.close()