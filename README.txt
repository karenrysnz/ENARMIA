ENARMIA V6 — ONBOARDING

1) Supabase > SQL Editor > ejecuta enarmia_v6_migration.sql. Este script es autocontenido: incluye materiales, preferencias y el bucket privado de calendarios.
2) Espera Success.
3) Sube enarmia_v6_index.html a Vercel como nuevo deployment de ENARMIA.
4) Abre la URL pública. Tras iniciar sesión aparecerá la bienvenida y el asistente de configuración.

Flujo: bienvenida -> objetivo -> tiempo -> preguntas/temas -> cómo aprendes -> prioridades + calendario -> estilo del tutor -> resumen.

El calendario sí se guarda en Storage privado. El siguiente paso será leer automáticamente PDF/Excel/Word con una función del servidor y convertir el calendario en tareas del plan diario.
Deploy ENARMIA conectado
