# FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build  # niet meer compatibel met de gebruikte OPA SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
EXPOSE 5172

WORKDIR /app
COPY . .

ENTRYPOINT ["dotnet", "watch", "run"]