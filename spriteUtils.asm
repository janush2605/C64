!source "constants.asm"

sprite0Block = 255 * 64
sprite1Block = 254 * 64
sprite2Block = 253 * 64
sprite3Block = 252 * 64
sprite4Block = 251 * 64
sprite5Block = 250 * 64
sprite6Block = 249 * 64
sprite7Block = 248 * 64

!macro showSprite .index {
	lda vic+21
	ora #2^.index
	sta vic+21 
}

!macro setSpriteBlockAddress .address, .block {
	lda #.block
	sta .address
}

!macro loadSpriteData .startBlock, .startDataAddress {
	!set .index = 0
	!for .index, 63 {
		LDX #.index
		LDA .startDataAddress,X
		STA .startBlock,X
	}	     
}

!macro setSpritePosition .index, .x, .y {
		ldx #.x
		stx vic + 2 * .index
		ldy #.y
		sty vic + 2 * .index + 1
}
