from fastapi import APIRouter, UploadFile, File, HTTPException
import uuid

router = APIRouter(
    prefix="/media",
    tags=["Media"]
)

@router.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    # Validate content type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are allowed")

    # Generate unique filename
    file_extension = file.filename.split(".")[-1] if "." in file.filename else "jpg"
    unique_filename = f"{uuid.uuid4()}.{file_extension}"
    
    # Read file size (Simulated upload)
    file_content = await file.read()
    file_size = len(file_content)

    # Mock Storage URL
    mock_url = f"https://fake-storage.com/{unique_filename}"

    return {
        "url": mock_url,
        "filename": unique_filename,
        "size": file_size
    }
