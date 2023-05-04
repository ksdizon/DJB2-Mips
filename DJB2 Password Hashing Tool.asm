# Password creation program
# Requirements
# 1. Your password must be 8-16 characters long
# 2. Must contain at least one lowercase character
# 3. Must contain at least one uppercase character
# 4. Must contain at least one special character
# 5. Should have no white spaces (Inculding horizontal tab)
# IMPORTANT: whitespace or horizontal tab before a typed character will not be counted as whitespace

# Uses range according to ASCII table to determine type of character
# 65 - 90 = uppercase char
# 97 - 122 = lowercase char
# 48 - 57 = integer char
# else = special char

# Registers used to store chaar type count
# $t0 - total char count
# $t2 - upperchar
# $t3 - lowerchar
# $t4 - special char
# $t5 - int char
# DJB2 HASH Registers
# $s0 - pointer used by DJB2 Hash code
# $t6 - 5381 (This value constatly gets updated for every character in the string)
# $t7 - pointer 
# $t8 - temporary variable used to hold value of  string shifted to 5# $t0 - 

.data
	password: .space 256
	#String variables
	requirements: .asciiz "Creating Password Program\n1] Your password must be 8-16 characters long\n2] Must contain at least one lower case character\n3] Must contain at least one upper case character\n4] Must contain at least one special character\n5] Should have no white spaces\nEnter Password -> "
	passlenword: .asciiz "~~~~~~~~~~~~~~~\nYOUR PASSWORD IS VALID!\nPASSWORD LENGTH: "
	upperCharCount: .asciiz "\nUPPER COUNT: "
	lowerCharCount: .asciiz "\nLOWER COUNT: "
	specialCharCount: .asciiz "\nSPEICAL COUNT: "
	intCharCount: .asciiz "\nINT COUNT: "
	result: .asciiz "\nHash value: "
	
	#Error Messages
	whiteSpaceErrorMsg: .asciiz "\nERROR: NO WHITE SPACE!\n"
	passLenShortErrorMsg: .asciiz "\nERROR: PASSWROD TOO SHORT. PASSWORD MUST BE 8-16 CHAR LONG!\n"
	passLenLongErrorMsg: .asciiz "\nERROR: PASSWORD TOO LONG. PASSWORD MUST BE 8-16 CHAR LONG!\n"
	upperCharErrorMsg: .asciiz "\nERROR: PASSWORD MUST CONTAIN AT LEAST 1 UPPERCASE CHAR!\n"
	lowerCharErrorMsg: .asciiz "\nERROR: PASSWORD MUST CONTAIN AT LEAST 1 LOWERCASE CHAR!\n"
	specialCharErrorMsg: .asciiz "\nERROR: PASSWORD MUST CONTAIN AT LEAST 1 SPECIAL CHAR!\n"
	intCharErrorMsg: .asciiz "\nERROR: PASSWORD MUST CONTAIN AT LEAST 1 INTEGER CHAR!\n"
	horizontalTabErrorMsg: .asciiz "\nERROR: PASSWROD MUST NOT CONTAIN HORIZONTAL TAB!\n"

.text
main:
start:
	#Print password requirements
	li $v0, 4	
	la $a0, requirements
	syscall
	#Retrieve password
	li $v0, 8
	la $a0, password
	li $a1, 256
	syscall
	
	# set $s0 to the start of the string (Used by DJB2 code)
	move $s0, $a0
	
	la $a0, password # Loading password address
	
	jal passlen # initialize counter of pass len start of loop
	ble $t0, 7, passLenShortFail # check pass length
	bge $t0, 16, passLenLongFail # check pass length > 16
	beq $t2, 0, upperCharFail # check uppercase count > 0
	beq $t3, 0, lowerCharFail # check lowercase count > 0
	beq $t4, 0, specialCharFail # check special char count > 0
	beq $t5, 0, intCharFail
	jal print # Prints if password meets requirements
	jal djb2 # Jumps to hash password
	j exit
	
# Function that initializes variables
passlen:
	li $t0, -1 # initalize password counter 0 (Set to -1 to remove value of null from being counted)
	li $t2, 0 # initialize upper count
	li $t3, 0 # initialze lower count
	li $t4, -1 # special char count (Set to -1 to remove value of null from being counted)
	li $t5, 0 # initialize int char count

loop:
	lb $t1, ($a0)
	beqz $t1, return
	beq $t1, ' ', whiteSpaceFail # returns invalid if char is whitespace
	beq $t1, 9, horizontalTabFail # returns invailid if char is horizontal tab
	addi $t0, $t0, 1 # Increments password length
	j checkChar # Counts number of upper, lower, special, int chars

	# Function that increments pointer	
	incrementPointer:
		addi $a0, $a0, 1
		j loop

# Displays when creation is successful and breakdown of char types used
print:
	# Password length
	li $v0, 4
	la $a0, passlenword
	syscall

	li $v0, 1
	move $a0, $t0
	syscall
	
	# Uppercase char count
	li $v0, 4
	la $a0, upperCharCount
	syscall
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	# Lowercase char count
	li $v0, 4
	la $a0, lowerCharCount
	syscall
	
	li $v0, 1
	move $a0, $t3
	syscall
	
	# Special char count
	li $v0, 4
	la $a0, specialCharCount
	syscall
	
	li $v0, 1
	move $a0, $t4
	syscall
	
	# Int char count
	li $v0, 4
	la $a0, intCharCount
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	j return

# Functions below determine type of char
	checkChar:	
		# Checks first if char is within 48-57 decimal ascii range (0 - 9)
		ble $t1, 57, intChar
	
		# Checks if char is within 65-90 decimal ascii range (A - Z)
		bgt $t1, 90, lowerChar	# Will branch to check if char is lowercase
		blt $t1, 65, specialChar # Will branch to check if char is special 
	
		# If code does not branch then char is within range of 65 - 90 (uppercase)
		addi $t2, $t2, 1 # Increments the uppercase count
		j incrementPointer

	lowerChar:
		bgt $t1, 122, specialChar
		blt $t1, 97, specialChar
		# If code does not branch then char is within range of 97 - 122 (lowercase)
		addi $t3, $t3, 1
		j incrementPointer

	specialChar:
		# Increments special char count
		addi $t4, $t4, 1
		j incrementPointer

	intChar:
		blt $t1, 48, specialChar # Checks first if less than 48 as 0-47 are other chars
		# If passed increments int char count
		addi $t5, $t5, 1
		j incrementPointer

# Failure Message Functions Below
	whiteSpaceFail:
		li $v0, 4
		la $a0, whiteSpaceErrorMsg
		syscall
		j start

	horizontalTabFail:
		li $v0, 4
		la $a0, horizontalTabErrorMsg
		syscall
		j start

	passLenShortFail:
		li $v0, 4
		la $a0, passLenShortErrorMsg
		syscall
		j start

	passLenLongFail:
		li $v0, 4
		la $a0, passLenLongErrorMsg
		syscall
		j start
		
	upperCharFail:
		li $v0, 4
		la $a0, upperCharErrorMsg
		syscall
		j start

	lowerCharFail:
		li $v0, 4
		la $a0, lowerCharErrorMsg
		syscall
		j start

	specialCharFail:
		li $v0, 4
		la $a0, specialCharErrorMsg
		syscall
		j start

	intCharFail:
		li $v0, 4
		la $a0, intCharErrorMsg
		syscall
		j start

# DJB2 Hash Algorithm Code
	djb2:
		# initialize hash to 5381
		li $t6, 5381

	hash_loop:
		# load the next character from the input into $t1
		lbu $t7, ($s0)

		# if $t1 is zero, we've reached the end of the input, so exit the loop
		beqz $t7, done

		# exclude null terminator from hash computation
		bne $t7, 10, skip

		# exit the loop if the null terminator is encountered
		j done

	skip:
		# update the hash: hash = hash * 33 + c
		sll $t8, $t6, 5
		addu $t6, $t8, $t6
		addu $t6, $t6, $t7

		# advance to the next character in the input
		addiu $s0, $s0, 1

		# repeat the loop for the next character
		j hash_loop

	done:
		# print the hash value
		li $v0, 4
		la $a0, result
		syscall

		li $v0, 36 # use 36 to print unsigned int!
		move $a0, $t6
		syscall

		j return
	
# Exit functions
exit:
	li $v0, 10
	syscall
	
return:
	jr $ra
