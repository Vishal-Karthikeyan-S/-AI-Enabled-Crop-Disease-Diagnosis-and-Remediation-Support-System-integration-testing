import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, models, transforms
from torch.utils.data import DataLoader
import os

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

train_transforms = transforms.Compose([
    transforms.RandomResizedCrop(224, scale=(0.8, 1.0)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomVerticalFlip(),
    transforms.RandomRotation(30),
    transforms.ColorJitter(
        brightness=0.3,
        contrast=0.3,
        saturation=0.3
    ),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485,0.456,0.406],
        std=[0.229,0.224,0.225]
    )
])

# LOAD DATASET
dataset = datasets.ImageFolder("dataset", transform=train_transforms)

# USE 25% DATA FOR FASTER TRAINING
small_dataset, _ = torch.utils.data.random_split(
    dataset,
    [int(len(dataset) * 0.25), len(dataset) - int(len(dataset) * 0.25)]
)

dataloader = DataLoader(
    small_dataset,
    batch_size=32,
    shuffle=True,
    num_workers=0
)

print(len(dataset))
print(device)

num_classes = len(dataset.classes)
print("Number of classes:", num_classes)

model = models.mobilenet_v2(weights="IMAGENET1K_V1")
for param in model.features.parameters():
    param.requires_grad = False
model.classifier[1] = nn.Linear(model.last_channel, num_classes)
model = model.to(device)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.0001)

epochs = 12

for epoch in range(epochs):

    model.train()
    running_loss = 0
    correct = 0
    total = 0

    for images, labels in dataloader:
        images, labels = images.to(device), labels.to(device)

        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        running_loss += loss.item()

        _, predicted = torch.max(outputs, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

    train_acc = 100 * correct / total

    print(f"Epoch {epoch+1} | Loss: {running_loss:.4f} | Train Accuracy: {train_acc:.2f}%")

os.makedirs("app/model", exist_ok=True)
torch.save(model.state_dict(), "app/model/plant_model.pth")

print("Model saved successfully!")