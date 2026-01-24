# ETAPA 1: Construir la App Web con Flutter
# CAMBIO IMPORTANTE: Usamos 'stable' para tener la última versión de Dart/Flutter
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Configuración para evitar advertencias de permisos y descargas
RUN git config --global --add safe.directory /app

# Copiamos los archivos
COPY . .

# Descargamos dependencias
RUN flutter pub get

# Construimos la versión Web
RUN flutter build web --release

# ETAPA 2: Servir con Nginx
FROM nginx:alpine

# Copiamos los archivos construidos
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponemos el puerto 80
EXPOSE 80

# Arrancamos Nginx
CMD ["nginx", "-g", "daemon off;"]