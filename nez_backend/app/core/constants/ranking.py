# ============================================================
# RANKING CONSTANTS — Single source of truth for all scoring
# ============================================================
# Tune these values to adjust feed personalization behavior.
# No magic numbers scattered across the codebase.

# --- Recency Scoring ---
RECENCY_SCORE_TODAY = 50        # Article published today
RECENCY_SCORE_1_DAY = 30        # Published 1 day ago
RECENCY_SCORE_2_DAYS = 15       # Published 2 days ago
RECENCY_SCORE_OLD = 5           # Published 3+ days ago

# --- Category Preference ---
CATEGORY_WEIGHT_MULTIPLIER = 0.1    # read_time * this = weight added per interaction
CATEGORY_WEIGHT_MAX = 100.0         # Cap to prevent runaway scores
DEFAULT_CATEGORY_WEIGHT = 0.0       # Weight for unseen categories

# --- Engagement Scoring ---
ENGAGEMENT_VIEW_WEIGHT = 1.0        # Weight for a "view" interaction
ENGAGEMENT_READ_WEIGHT = 3.0        # Weight for a "read" interaction
ENGAGEMENT_LIKE_WEIGHT = 5.0        # Weight for a "like" interaction
ENGAGEMENT_SHARE_WEIGHT = 7.0       # Weight for a "share" interaction
ENGAGEMENT_BOOKMARK_WEIGHT = 4.0    # Weight for a "bookmark" interaction

# --- Read Time Thresholds ---
MIN_READ_TIME_SECONDS = 5          # Ignore interactions shorter than this (accidental clicks)
DEEP_READ_THRESHOLD = 60           # Seconds — considered a "deep read", bonus weight
DEEP_READ_BONUS = 10.0             # Extra score for deep reads

# --- Feed Defaults ---
DEFAULT_FEED_LIMIT = 20
MAX_FEED_LIMIT = 100
