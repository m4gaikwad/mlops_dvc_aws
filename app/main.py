# app/main.py
import pickle
from fastapi import FastAPI
from pydantic import BaseModel
import os

# Ensure model files exist
MODEL_PATH = "model/model.pkl"
VEC_PATH = "model/vectorizer.pkl"

if not (os.path.exists(MODEL_PATH) and os.path.exists(VEC_PATH)):
    raise RuntimeError("Model and vectorizer not found. Did you run `dvc pull`?")

with open(MODEL_PATH, "rb") as f:
    model = pickle.load(f)

with open(VEC_PATH, "rb") as f:
    vectorizer = pickle.load(f)

app = FastAPI(title="Spam Classifier API")

class TextInput(BaseModel):
    text: str

@app.get("/")
def root():
    return {"message": "Spam classifier API is running"}

@app.post("/predict")
def predict(input: TextInput):
    X = vectorizer.transform([input.text])
    pred = model.predict(X)[0]
    return {"text": input.text, "prediction": int(pred)}
