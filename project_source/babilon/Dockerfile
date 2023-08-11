
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env

# Copy csproj and restore dependencies
WORKDIR /source/Lib
COPY ./Lib/*.csproj .
RUN dotnet restore
COPY ./Lib/. .

WORKDIR /source/Server
COPY ./Server/*.csproj ./
RUN dotnet restore
COPY ./Server/. .

WORKDIR /source/Lib
RUN dotnet publish -c Release -o out/Lib
WORKDIR /source/Server
RUN dotnet publish -c Release -o out/Server

# Set working directory to the published Server app
WORKDIR /source/Server/out/Server
# Run the server application on container startup
CMD ["dotnet", "Server.dll"]