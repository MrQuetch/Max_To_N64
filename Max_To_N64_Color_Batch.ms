-- Note: Try to keep the models at 440 triangles or less.
-- If the model contains more than that, split it into smaller models.
-- Check through the generated code to make sure the "gsSPVertex" function is at array [1296] or less. ( The amount of [864] appears to work better. )
-- I'm not sure if that's the limit, but that appears to be a good number.
-- Especially from personal experience with the N64.

	(
	fn roundFloat val n = 
		(
		local mult = 10.0 ^ n
		(floor ((val * mult) + 0.5)) / mult
		)
	
	fStream = newScript()
	
	vert_count = 0
	--array_24 = #(24,48,72,96,120,144,168,192,216,240,264,288,312,336)
	--array_24_back = #(24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1)
	
	-- Make sure all meshes have vertex color already, or else the script will complain.
	
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
			format "    { %% %% %% 0% 0% 0% %% %% %% 255.0 }% // % \n" (roundFloat(vert_1.x*selection[i].scale.x)(2)) "," (roundFloat(vert_1.y*selection[i].scale.y)(2)) "," (roundFloat(vert_1.z*selection[i].scale.z)(2)) "," "," "," "," (floor(vColors[1])) "," (floor(vColors[2])) "," (floor(vColors[3])) "," "," (vert_count) to:fStream
			vert_count += 1
			format "    { %% %% %% 0% 0% 0% %% %% %% 255.0 }% // % \n" (roundFloat(vert_2.x*selection[i].scale.x)(2)) "," (roundFloat(vert_2.y*selection[i].scale.y)(2)) "," (roundFloat(vert_2.z*selection[i].scale.z)(2)) "," "," "," "," (floor(vColors[4])) "," (floor(vColors[5])) "," (floor(vColors[6])) "," "," (vert_count) to:fStream
			vert_count += 1
			format "    { %% %% %% 0% 0% 0% %% %% %% 255.0 }% // % \n" (roundFloat(vert_3.x*selection[i].scale.x)(2)) "," (roundFloat(vert_3.y*selection[i].scale.y)(2)) "," (roundFloat(vert_3.z*selection[i].scale.z)(2)) "," "," "," "," (floor(vColors[7])) "," (floor(vColors[8])) "," (floor(vColors[9])) "," "," (vert_count) to:fStream
			vert_count += 1
			)
		
		format "    }; \n" to:fStream
		format " \n" to:fStream
		)
	
	for i = 1 to selection.count do
		(
		format "Gfx %_dl[] = \n" (selection[i].name) to:fStream
		format "    { \n" to:fStream
		format "    gsDPPipeSync(), \n" to:fStream
		format "    gsDPSetCycleType(G_CYC_1CYCLE), \n" to:fStream
		format "    gsDPSetRenderMode(G_RM_AA_ZB_OPA_SURF, G_RM_AA_ZB_OPA_SURF2), \n" to:fStream
		format "    gsSPClearGeometryMode(0xFFFFFFFF), \n" to:fStream
		format " \n" to:fStream
		format "    gsSPSetGeometryMode(G_ZBUFFER|G_CULL_BACK|G_SHADE|G_SHADING_SMOOTH), \n" to:fStream
		format " \n" to:fStream
		format "    gsDPSetColorDither(G_CD_BAYER), \n" to:fStream
		format "    gsDPSetCombineMode(G_CC_SHADE, G_CC_SHADE), \n" to:fStream
		format " \n" to:fStream
		
		tri_count = 0
		final_count = 0
		count_24 = 0
		
		for f = 1 to selection[i].mesh.numfaces do
			(
			--format "// % \n" (f) to:fStream -- triangle count
			
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
		
		/*
		for j = 1 to 10 do
			(
			if (full_count > array_24[j] and full_count < array_24[j + 1]) do
				(
				final_check = array_24[j]+3 - last_count
				format "    gsSPVertex(&(%_elements[%])%%%%), \n" (selection[i].name) (count_24) "," (final_check) "," (0) to:fStream
				)
			)
		*/
		
		format "    gsSPEndDisplayList(), \n" to:fStream
		format "    }; \n" to:fStream
		)
	)