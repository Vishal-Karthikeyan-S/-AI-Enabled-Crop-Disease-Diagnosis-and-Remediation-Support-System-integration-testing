# Use official Python 3.11 slim image for lighter weight
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy dependency list to leverage Docker cache layer
COPY requirements.txt .

# Install required Python dependencies
# We use --no-cache-dir to reduce image size by not storing the pip cache
RUN pip install --no-cache-dir -r requirements.txt

# Create necessary directories for the application and database
RUN mkdir -p /app/uploads

# Copy the actual application files
COPY . .

# Expose the API port
EXPOSE 8000

# Start FastAPI exactly as requested
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
