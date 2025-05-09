# ArcadeTemplate
 Template Repo for building Godot Games for the FCHS Arcade Cabinet

DogeFire Duo - Retro Bullet-Hell Arcade Shooter
Description of the Project:
DogeFire Duo is a two-player cooperative bullet‑hell shooter made in Godot 4.4. 
Think classic side‑scroll shooters.  
You and a friend shoot through waves of enemies, unlock new weapons, 
and try to build up the highest scores together. The game focuses on teamwork, *if in two player mode*
quick reflexes, and smart weapon choices. the player/players have to get through 5 levels each one becoming harder from the last.
Menus are easy to navigate, and the controls feel good and consistent across all levels.
when the game is in one player mode the player will be given 3 hearts to simulate the same 3 revives the players
get in the two player mode. 


Gameplay Features Chosen to be Graded:
	
Controls – The game supports full joystick integration with support for start and at least 5 other buttons per player.
 The controls become intuitive within a few minutes of gameplay and allow both players to move, shoot, switch weapons,
 and use a pause menu.


UI Design – The game has more than 3 menus and HUDs that follow CRAP principles (contrast, 
repetition, alignment, and proximity). This includes the main menu, mainmenu_2, pause menu, and weapon unlock scree. 
UI components are clean, themed, and have usability with clarity and consistency.


Scoring – Players can meaningfully compare performance with a leaderboard that displays the top 10 scores of both scoress added together as well as the individual scores of each player.
 Scores are reset between sessions, except the item list leaderboard scores, they are saved through json. players cannot input custom names (as allowed).
 The leaderboard is displayed after the game ends and reflects the most resent session scores.


Multiplayer – Two players can play simultaneously with shared objectives. In cooperative gameplay, players must collaborate to defeat enemies, 
and can revive each other when in two player mode. The revive logic is robust and accounts for multiple edge cases, such as both players dying or one 
player attempting a revive under specific timing conditions because of the 10 timer to revive. 


Delivery on Proposal – The game meets all planned mechanics, almost features, and aesthetic goals listed in the project proposal.
. The gameplay matches what was said in the project proposal but different sprites were used for a lot of the game and 
we were not able to fit in the powerups into our game. 


Instructions on How to Test Each Chosen Feature and Where to Find the Related Scenes and Scripts:
	
	
Controls:
 Test by connecting two controllers. Start the game from MainMenu.tscn and control each player’s movement and shooting 
in levels like mainLvl_1.tscn through mainLvl_5.tscn.
 Scripts that manage controls: characterBody_P1.gd and characterBody_P2.gd.


UI Design:
 Navigate through the game from MainMenu.tscn. Screens to test include loading_screen.tscn,
 weapon_unlock_screen.tscn, pauseMenu2P.tscn, ScoreScene.tscn, winScreen.tscn, and YouDiedScreen.tscn.
 Corresponding scripts: main_menu.gd, pause_menu_2p.gd, weapon_unlock_screen.gd, and score_scene.gd.


Scoring:
 Complete a play session and let the ScoreScene.tscn appear. Observe the top 10 scores.
 Script responsible for scoring: score_scene.gd. ou could set the time limit per levle to 5 seoncds 
and just get one kill then wait for the winscreen and see the leaderboard, then you could die in the first 
level after getting a kill or two and see that the leader board does not delete the json leaderboard. 


Multiplayer:
 Start the game with two controllers select the two polayer game most and press start for both players.
 Observe cooperative gameplay and revive mechanics by letting one player die and reviving from the other. 
Test in levels mainLvl_1.tscn and up. Scripts: characterBody_P1.gd, characterBody_P2.gd, and relevant logic in main.gd.



Examples of OOP Concepts and Godot Features to Be Graded:
	
	
Inheritance:
  enemy 1 and 2 scripts inherit from EnemyBase.gd, and weapon types inherit shared functionality. 
This allows shared logic and customization in subclasses. an example of this is 

extends EnemyBase 
in the enemy_1.gd


Encapsulation:
 Variables within the player and enemy scripts are marked private with "_" 
and used across methods without direct external access. 
Encapsulation is evident in managing health, speed, and states. one example is in the enemy1_bullet.gd. 
@export var _speed = 300
@export var _damage := 10

func _physics_process(delta):
	position.x -= _speed * delta
	
The variables _speed and _damage are marked with a leading underscore to indicate they are intended for internal use only.
	

Polymorphism:
 The game uses polymorphism to interact with player and enemy objects through base types. 
For example, various weapons use a shared shooting function that adapts behavior depending on the weapon type.
an example of this can be found in enemy1_bullet.gd

@export var _damage := 10
...
func _on_body_entered(body):
	if body.name == "CharacterBodyP1" or body.name == "CharacterBodyP2":
		#Handle collision using polymorphism
		body.take_damage(_damage)
The bullet doesn't need to know what specific type the body is—it only checks if the name matches expected values. 



Abstraction:
 Abstract functions are declared in weapon base classes and implemented uniquely by each weapon script, 
ensuring extendable and modular behavior. bullets 1-3 use 
if body is EnemyBase:
	body.take_damage(damage, shooter_player)
and Enemybase.gd uses.
func die(shooter_player := 1) -> void:
	assert(false, "Child class must override die() method")

 The EnemyBase script defines an abstract die() method that is not meant to be used directly.
 Instead, each child class (e.g., enemy_1.gd, enemy_2.gd, etc.) must override it with their own behavior. 
Using assert(false, "Child class must override die() method") enforces that this method must be implemented, 
or the game will crash


Godot Features:
 Custom signals are used throughout the project for UI to emit the keyboard inputs, 
 Scenes are  instanced using node trees made up of differnet nodes. 



Team Roles and Contributions:
	
Dan-
 Created parallax scrolling backgrounds using multiple layers and implemented theme environments. 
Later focused on polishing the UI screens for readability, aesthetic, and usability based on CRAP principles.
Gavy –
 Rewrote gameplay systems for improved performance and player experience.
 Handled revive logic, health management for 1P and 2P, and made sure UI integration was functional and reactive.
Jerry -
 Designed and implemented multiple enemy types with varied bullet patterns. as well as the
starting wepaon switching logic along with the wepaons bullets. also helped with debugging the game
Logan-
did the same stuff as dan but not for the parallax backgrounds.
TJones -
 Coordinated the team using Git branching and pull requests. Enforced consistent naming conventions, 
folder structure, and finalized documentation. Managed bug tracking and collaborated on core gameplay flow. 
also helped debug the game.



Google Drive Link for External Files:
https://drive.google.com/drive/folders/1XeTxwIEFBsOy-NXvRFtsELSReDlGMIcv?usp=drive_link
All external PSDs, sprite files, and audio resources are available in the Google Drive folder above
Note: Reflections were submitted late in the sprint cycle, leading to a 6/10 score for that section according to the rubric.
 but each person work and reflect their challenges, lessons learned, and accomplishments.
