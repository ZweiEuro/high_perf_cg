# To be done
Make a controller that spawns lightning indicators around the player
	They should have some visual indicator of when the lightning will strike the ground there
	When they expire they spawn the actual lightning node that then does the cool effect/shader
		Note: would be cool to leave be hind scorch marks
	
	
The lightning indicators:+
		the indicators are spawned by the game master / controller in a random area 
		Around the current players position.
		
The lightning node:
	Should use the cool shader we found:
			https://www.youtube.com/watch?v=C5g3Zdvitg4
	Spawns a collider at the end that actually makes the collision check with the player and we show a counter
	
----------------------
TODO
- fix shitty lightning shapes
- combine indicators with lightning spawn-despawn
- sound effect/scorch mark / particle etc to make it... integrate? better to the scene
