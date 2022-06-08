# AngelscriptSonar
Rudimentary Sonar for Sven Co-op. In Angelscript

To install:
Un-zip into /Sven Co-op/svencoop so that sonar.as ends up in /maps/scripts

To add to map script, call Sonar::Init() in the MapStart() function as shown below:

void MapStart()
{
  Sonar::Init()
}
 
To setup in Hammer:
Have an entity to project the sonar (func_vehicle_custom for example)
Create your trigger_script at the center of your sonar display
Turn off Smart-Edit and add the following keys to your trigger_script with the appropriate values as listed

$s_sourceName - Name of entity which projects sonar (e.g. func_vehicle_custom)
$f_sonarRadius - Radius of sonar projection, in map units, around the source
$f_displayRadius - Radius around trigger_script entity to project points, also in map units
$s_triggerPing -  Name of entities(e.g. ambient_generic for sound) to play for initial ping
$s_triggerPong - Name of entities(e.g. ambient_generic for sound) to play for pong responses
