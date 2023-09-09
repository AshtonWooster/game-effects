--Server TextPacket README
--Ashton
--1.6.23 -- 1.7.23

- Send a TextPacket object to the client to display text

- Constructor
	TextPacket.new( [ text ] )
		- [ text ]: the text to be displayed with text modifiers opened by "<" and ">", terminated with additional ">"

- Syntax
	- [ < ]: used to open modifiers
	- [ > ]: used to close modifiers when used once, and cancel when used twice
	- [ ; ]: used to seperate modifiers
	- [ , ]: used to separate parameters for modifiers

- Modifiers
	- [ Size,x ]: 	   sets the size of the text equal to x
	- [ Color,r,g,b ]: sets the color of the text to the rgb color3 (r, g, b)
	- [ Font,f ]: 	   sets the text font to f
	- [ Bold ]:		   bolds the text
	- [ Italic ]:	   italaics the text
	
 EX: "<Size,10;Color,255,0,0>Ashton><Size,5;Color,255,255,255> Hey guys!>"
 EX: "Hello everyone!" (will be given a default text modifier block)