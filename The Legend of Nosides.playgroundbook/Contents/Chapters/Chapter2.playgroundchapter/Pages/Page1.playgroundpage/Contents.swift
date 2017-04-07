//#-hidden-code
//  Contents.swift
//#-end-hidden-code

/*:
 ### Chapter 2: Hate Spawns
 
 Everywhere, everyshape began to call this shape Nosides, and hate surrounded him. He shrunk in size and confidence everytime a new hater entered his life. 
 
 */

import PlaygroundSupport

//Tap the screen to add hate.
//After adding enough hate, go to the next chapter.

let HateSpawn = HateSpawnsViewController()

//Adjust the hate limit to adjust how many triangles can appear.
HateSpawn.hateLimit = 8

PlaygroundPage.current.liveView = HateSpawn
