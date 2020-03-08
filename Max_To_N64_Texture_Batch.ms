	(
	fn roundFloat val n = 
		(
		local mult = 10.0 ^ n
		(floor ((val * mult) + 0.5)) / mult
		)
	
	fStream = newScript()
	
	vert_count = 0
	texture_size = 32
	
	-- Make sure all meshes have vertex color already, or else the script will complain.
	-- Also make sure that all meshes are mapped, and already have textures - otherwise more complaining.
	
	-- vertices
	for i = 1 to selection.count do
		(
		format "Vtx %_elements[] = \n" (selection[i].name) to:fStream
		format "    { \n" to:fStream
		
		for f = 1 to selection[i].mesh.numfaces do
			(
			-- vertex positions
			face = GetFace selection[i].mesh f
			
			-- face positions
			vert_1 = GetVert selection[i].mesh face.x * selection[i].objecttransform
			vert_2 = GetVert selection[i].mesh face.y * selection[i].objecttransform
			vert_3 = GetVert selection[i].mesh face.z * selection[i].objecttransform
			
			-- vertex textures
			faceTex = GetTVFace selection[i].mesh f
			vertTex_1 = GetTVert selection[i].mesh faceTex.x
			vertTex_2 = GetTVert selection[i].mesh faceTex.y
			vertTex_3 = GetTVert selection[i].mesh faceTex.z
			
			vertTex_1_x = vertTex_1.x
			vertTex_1_y = vertTex_1.y
			
			vertTex_2_x = vertTex_2.x
			vertTex_2_y = vertTex_2.y
			
			vertTex_3_x = vertTex_3.x
			vertTex_3_y = vertTex_3.y
			
			-- vertex colors
			mapVerts = meshop.getMapVertsUsingMapFace selection[i].mesh 0 f
			vColors = #()
			
			-- get vertex colors
			for m in mapVerts where mapVerts[m] do
				(
				vColor = (meshop.getMapVert selection[i].mesh 0 m) * 255.0
				append vColors (vColor.x)
				append vColors (vColor.y)
				append vColors (vColor.z)
				)
			
			-- vertex elements
			format "    { %% %% %% 0% ((const int)% << 6)% ((const int)% << 6)% %% %% %% 255.0 }% // % \n" (roundFloat(vert_1.x*selection[i].scale.x)(2)) "," (roundFloat(vert_1.y*selection[i].scale.y)(2)) "," (roundFloat(vert_1.z*selection[i].scale.z)(2)) "," "," (roundFloat(vertTex_1_x*texture_size)(3)) "," (roundFloat(vertTex_1_y*texture_size)(3)) "," (floor(vColors[1])) "," (floor(vColors[2])) "," (floor(vColors[3])) "," "," (vert_count) to:fStream
			vert_count += 1
			format "    { %% %% %% 0% ((const int)% << 6)% ((const int)% << 6)% %% %% %% 255.0 }% // % \n" (roundFloat(vert_2.x*selection[i].scale.x)(2)) "," (roundFloat(vert_2.y*selection[i].scale.y)(2)) "," (roundFloat(vert_2.z*selection[i].scale.z)(2)) "," "," (roundFloat(vertTex_2_x*texture_size)(3)) "," (roundFloat(vertTex_2_y*texture_size)(3)) "," (floor(vColors[4])) "," (floor(vColors[5])) "," (floor(vColors[6])) "," "," (vert_count) to:fStream
			vert_count += 1
			format "    { %% %% %% 0% ((const int)% << 6)% ((const int)% << 6)% %% %% %% 255.0 }% // % \n" (roundFloat(vert_3.x*selection[i].scale.x)(2)) "," (roundFloat(vert_3.y*selection[i].scale.y)(2)) "," (roundFloat(vert_3.z*selection[i].scale.z)(2)) "," "," (roundFloat(vertTex_3_x*texture_size)(3)) "," (roundFloat(vertTex_3_y*texture_size)(3)) "," (floor(vColors[7])) "," (floor(vColors[8])) "," (floor(vColors[9])) "," "," (vert_count) to:fStream
			vert_count += 1
			)
		
		format "    }; \n" to:fStream
		format " \n" to:fStream
		)

	-- textures
	for k = 1 to selection.count do
		(
		aBitmap = (openBitmap selection[k].material.diffusemap.filename)

		aHeight = aBitmap.height
		aWidth = aBitmap.width

		count = 0

		format "// %x% \n" (aHeight) (aWidth) to:fStream
		format "unsigned int %[] = \n" (getFilenameFile(aBitmap.filename)) to:fStream
		format "    { \n" to:fStream

		for i = 0 to (aHeight-1) do
			(
			aRow = getPixels aBitmap [0, i] aWidth
			
			for j = 1 to aWidth do
				(
				aPixelColor = [ aRow[j].red, aRow[j].green, aRow[j].blue]
				
				format "0x" to:fStream
				
				if (aPixelColor[1] < 16) then
					(
					format "0%" (toUpper (bit.intAsHex(aPixelColor[1]))) to:fStream
					)
				else
					(
					format "%" (toUpper (bit.intAsHex(aPixelColor[1]))) to:fStream
					)
				if (aPixelColor[2] < 16) then
					(
					format "0%" (toUpper (bit.intAsHex(aPixelColor[2]))) to:fStream
					)
				else
					(
					format "%" (toUpper (bit.intAsHex(aPixelColor[2]))) to:fStream
					)
				if (aPixelColor[3] < 16) then
					(
					format "0%" (toUpper (bit.intAsHex(aPixelColor[3]))) to:fStream
					)
				else
					(
					format "%" (toUpper (bit.intAsHex(aPixelColor[3]))) to:fStream
					)
				
				format "FF," to:fStream
				
				count += 1
				/*
				if (count >= 32) do
					(
					format "\n" to:fStream
					count = 0
					)
				*/
				
				if (count >= 16) do
					(
					format "\n" to:fStream
					count = 0
					)
				)
			)
		
		format "    }; \n" to:fStream
		format " \n" to:fStream
		)
	
	-- triangles
	for i = 1 to selection.count do
		(
		aBitmap = (openBitmap selection[i].material.diffusemap.filename)
		
		aHeight = aBitmap.height
		aWidth = aBitmap.width
		
		format "Gfx %_dl[] = \n" (selection[i].name) to:fStream
		format "    { \n" to:fStream
		format "    gsDPPipeSync(), \n" to:fStream
		format "    gsDPSetCycleType(G_CYC_1CYCLE), \n" to:fStream
		format "    gsDPSetRenderMode(G_RM_AA_ZB_OPA_SURF, G_RM_AA_ZB_OPA_SURF2), \n" to:fStream
		format "    gsSPClearGeometryMode(0xFFFFFFFF), \n" to:fStream
		format " \n" to:fStream
		format "    gsSPSetGeometryMode(G_ZBUFFER|G_CULL_BACK|G_SHADE|G_SHADING_SMOOTH|G_TEXTURE_GEN|G_TEXTURE_GEN_LINEAR), \n" to:fStream
		format " \n" to:fStream
		format "    gsSPTexture(0x8000, 0x8000, 0, G_TX_RENDERTILE, G_ON), \n" to:fStream
		format "    gsDPLoadTextureBlock(%, G_IM_FMT_RGBA, G_IM_SIZ_32b, %, %, 0, \n" (getFilenameFile(aBitmap.filename)) (aHeight) (aWidth) to:fStream
		format "                                   G_TX_WRAP | G_TX_MIRROR, G_TX_WRAP | G_TX_MIRROR, \n" to:fStream
		format "                                   5, 5, G_TX_NOLOD, G_TX_NOLOD), \n" to:fStream -- still need to change the '5, 5,' for other image sizes
		format " \n" to:fStream
		format "    gsDPSetColorDither(G_CD_BAYER), \n" to:fStream
		format "    gsDPSetCombineMode(G_CC_MODULATERGB, G_CC_MODULATERGB), \n" to:fStream
		format " \n" to:fStream
		format "    gsDPSetTextureFilter(G_TF_BILERP), \n" to:fStream
		format " \n" to:fStream
		
		/*
		if (selection[i].material != undefined) do
			(
			if (selection[i].material.diffusemap.filename != undefined) do
				(
				format "%" (selection[i].material.diffusemap.filename) to:fStream
				)
			)
		*/
		
		tri_count = 0
		final_count = 0
		count_24 = 0
		
		for f = 1 to selection[i].mesh.numfaces do
			(
			-- check the first one
			if (f == 1) do
				(
				-- check the first 8 triangles
				if (selection[i].mesh.numfaces > 8) then
					(
					format "    gsSPVertex(&(%_elements[%])%%%%), \n" (selection[i].name) (0) "," (24) "," (0) to:fStream
					)
				else
					(
					format "    gsSPVertex(&(%_elements[%])%%%%), \n" (selection[i].name) (0) "," (selection[i].mesh.numfaces*3) "," (0) to:fStream
					)
				)
			
			format "    gsSP1Triangle(%% %% %% 0), \n" (tri_count+0) "," (tri_count+1) "," (tri_count+2) "," to:fStream
			tri_count += 3
			
			-- check the last 8 triangles
			for j = 1 to 8 do
				(
				if (f == (selection[i].mesh.numfaces - j)) do
					(
					final_count = (j*3)
					)
				)
			
			if (tri_count >= 24) then
				(
				count_24 += 24
				
				-- check for the last one, and only put this where it needs to be
				if (f != (selection[i].mesh.numfaces)) do
					(
					format "    gsSPVertex(&(%_elements[%])%%%%), \n" (selection[i].name) (count_24) "," (final_count) "," (0) to:fStream
					)
				
				tri_count = 0
				)
			else
				(
				final_count = (tri_count+3)
				)
			)
		
		format "    gsSPTexture(0, 0, 0, 0, G_OFF), \n" to:fStream
		format "    gsSPEndDisplayList(), \n" to:fStream
		format "    }; \n" to:fStream
		format " \n" to:fStream
		)
	)