# Shop wait: owner guide / Guía para los dueños

**Setup pending:** use this guide after the backend is activated and each owner
has their own account. The owner page route is `/app/#/owner` on the configured
review site; the project administrator will provide the working link. A page
showing “Owner access is not connected yet” is not ready for use.

**Configuración pendiente:** use esta guía cuando el sistema esté activado y cada
dueño tenga su propia cuenta. La ruta de acceso es `/app/#/owner` en el sitio de
revisión configurado; el administrador del proyecto les dará el enlace que
funciona. Si aparece “El acceso de los dueños aún no está conectado”, todavía no está
listo para usarse.

## English

Both owners have the same access. Use your own account; either owner can update
the shop's shared status.

The estimate means **how long a customer may wait before service starts**. It is
not the time to finish their car, a reservation, or a guaranteed start time. The
customer display notes that the estimate may change.

### Publish an update

1. Open the supplied owner link and sign in with your email and password.
2. Choose **Available**, **Getting busy**, **Very busy**, or **Closed**.
3. For an open status, select an estimated wait range in minutes. Options run
   from **0–15** through **180–240**. Choose the range that reflects the shop now.
4. Under **Hide this estimate unless refreshed within**, choose **15, 30, or
   60 minutes**. This is how long the update stays current, not the customer wait.
5. Press **Update wait**. Changing selections alone does not publish anything.
6. Wait for **Saved. Customers can now see this update.** Check the customer
   status card. Connected customer screens update automatically; allow a few
   seconds for the new value to appear.

Publish again when conditions change or before the estimate expires if it is
still accurate. After expiry, customers see that the current wait is unavailable
and are directed to call. **Closed** also expires and has no wait range; it does
not edit the website's regular business hours.

### If something goes wrong

| What you see | What to do |
| --- | --- |
| The status changed while you were editing | The latest values are reloaded after a conflicting save. Review the other owner's update, choose any needed changes, and publish again. |
| Update could not be confirmed | Do not assume it failed or saved. Press **Reload latest status**, check the displayed values, then decide whether to update again. |
| Current wait unavailable | The update may have expired or the connection may be unavailable. Check the connection and reload; publish a fresh estimate when access works again. |
| Sign-in or access problem | Check your account details and connection. Contact the project administrator if it continues or you need a password reset. There is no public account signup or self-service reset yet. |

Use **Sign out** when finished, especially on a shared device. A full page reload
or app restart also requires signing in again because login is kept only while
the app is running. If sign-out reports an error, local access is cleared, but
the server could not confirm session revocation; contact the administrator if
you need that session revoked.

## Español

Los dos dueños tienen el mismo acceso. Cada uno usa su propia cuenta y puede
actualizar el estado compartido del taller.

La estimación indica **cuánto podría esperar un cliente antes de que empiece el
servicio**. No indica cuándo terminará el carro, no reserva un lugar y no
garantiza una hora de inicio. La pantalla del cliente aclara que puede cambiar.

### Publicar una actualización

1. Abra el enlace proporcionado e inicie sesión con su correo y contraseña.
2. Elija **Disponible**, **Algo ocupado**, **Muy ocupado** o **Cerrado**.
3. Si está abierto, elija un rango de espera en minutos. Las opciones van de
   **0–15** a **180–240**. Elija el rango que corresponda a la situación actual.
4. En **Ocultar esta estimación si no se actualiza en**, elija **15, 30 o
   60 minutos**. Este plazo indica cuánto dura la actualización; no es la espera
   del cliente.
5. Pulse **Actualizar espera**. Cambiar las opciones sin pulsar el botón no
   publica nada.
6. Espere el mensaje **Guardado. Los clientes ya pueden ver esta actualización.**
   Revise la tarjeta que muestra el estado al cliente. Las pantallas conectadas
   se actualizan automáticamente; el cambio puede tardar unos segundos.

Actualice cuando cambie la situación o antes de que venza el plazo si la
estimación sigue siendo correcta. Al vencer, la pantalla indica que la espera
actual no está disponible y pide llamar. **Cerrado** también vence y no lleva un
rango de espera; no cambia el horario habitual publicado en el sitio.

### Si hay un problema

| Lo que aparece | Qué hacer |
| --- | --- |
| El estado cambió mientras usted lo editaba | Después de detectar el conflicto al guardar, se cargan los datos más recientes. Revise la actualización del otro dueño, haga los cambios necesarios y vuelva a publicar. |
| No se pudo confirmar la actualización | No dé por hecho que se guardó o que falló. Pulse **Cargar el estado más reciente**, revise los valores y decida si debe actualizar de nuevo. |
| La espera actual no está disponible | La actualización pudo vencer o puede haber un problema de conexión. Revise la conexión y vuelva a cargar; publique una estimación nueva cuando tenga acceso. |
| Problema al iniciar sesión o acceder | Revise su correo, contraseña y conexión. Si continúa el problema o necesita cambiar su contraseña, contacte al administrador del proyecto. Todavía no hay registro público ni recuperación de contraseña desde la aplicación. |

Pulse **Cerrar sesión** al terminar, especialmente en un dispositivo compartido.
Al recargar completamente la página o reiniciar la aplicación tendrá que iniciar
sesión de nuevo. Si aparece un error al cerrar sesión, el acceso en ese
dispositivo se borra, pero el servidor no pudo confirmar la cancelación de la
sesión; contacte al administrador si necesita cancelarla en el servidor.
