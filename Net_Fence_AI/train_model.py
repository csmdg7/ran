import pandas as pd
import numpy as np
from sklearn.ensemble import IsolationForest
import joblib

# 1. Generate Comprehensive Training Data
# Features: [Signal_Strength, Is_Open_Network, Is_Duplicate_SSID]
# Signal: -30 (Strong) to -90 (Weak)
# Is_Open: 1 = Open, 0 = Secure
# Is_Duplicate: 1 = Yes, 0 = No
data = [
    [-40, 0, 0], [-50, 0, 0], [-60, 0, 0], [-30, 0, 0], # Normal Secure
    [-80, 0, 0], [-70, 0, 0], [-45, 0, 0], [-55, 0, 0], # Normal Secure
    [-20, 1, 1], [-15, 1, 1], [-25, 1, 1]              # Rogue Signatures
]

df = pd.DataFrame(data, columns=['signal', 'open', 'duplicate'])

# 2. Train the Isolation Forest
# We set contamination to 0.1 (10% expected anomalies)
model = IsolationForest(contamination=0.1, random_state=42)
model.fit(df)

# 3. Save the brain permanently
joblib.dump(model, 'netfence_brain.pkl')
print("✅ SUCCESS: AI Model trained and saved as 'netfence_brain.pkl'")