# AngelscriptSonar
Rudimentary Sonar for Sven Co-op. In Angelscript

!!!IMPORTANT NOTE!!!
Beta 1.0 includes logic to offset the rotation of the sonar projection based on a quirk of func_vehicle_custom starting facing west but most entities starting east. This will be improved in the future to include a toggle between a mobile sonar, stationary, and func_vehicle_custom corrected rotation modes

To install:
Un-zip into /Sven Co-op/svencoop so that sonar.as ends up in /maps/scripts

To add to map script, call Sonar::Init() in the MapStart() function as shown below:

void MapStart() <br>
{ <br>
  &nbsp;&nbsp;Sonar::Init(); <br>
} <br>
 
To setup in Hammer: <br>
Have an entity to project the sonar (func_vehicle_custom for example) <br>
Create your trigger_script at the center of your sonar display <br>
(I personally recommend you give it a map unit or two gap to help the sprite rendering)<br>
Turn off Smart-Edit and add the following keys to your trigger_script with the appropriate values as listed: <br>
<br>
$s_sourceName - Name of entity which projects sonar (e.g. func_vehicle_custom) <br>
$f_sonarRadius - Radius of sonar projection, in map units, around the source <br>
$f_displayRadius - Radius around trigger_script entity to project points, also in map units <br>
$s_triggerPing -  Name of entities(e.g. ambient_generic for sound) to play for initial ping <br>
$s_triggerPong - Name of entities(e.g. ambient_generic for sound) to play for pong responses <br>
