mesh_x:
	.db 240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240
	.db 240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240
	.db 240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240
	.db 240,240,240,240,240,240,240,240,240,240,240
mesh_angle:
	.db  32, 19, 32, 45,160,147,160,173,237,224,211,224,109, 96, 83, 96
	.db  70, 83,115,128,128,184,200,  0,  0, 13, 45, 58,  8, 26, 48, 64
	.db  71, 72, 88,118,128,138,168,184,185,192,208,230,248,104, 74, 83
	.db 101,192,205,211,224,237,243,  0,  0,224,192
mesh_radius:
	.db  23, 36, 45, 36, 23, 36, 45, 36, 36, 23, 36, 45, 36, 23, 36, 45
	.db  57, 18, 51, 48,  8, 41, 41,  8, 48, 51, 18, 57, 41, 40, 43, 48
	.db  49, 41, 29, 33, 40, 33, 29, 41, 49, 48, 43, 40, 41, 29, 33, 54
	.db  51, 48, 51, 36, 45, 36, 51, 48, 16, 23, 16
mesh_angle_ptr.lo:
	.db low(mesh_angle+0)
	.db low(mesh_angle+4)
	.db low(mesh_angle+8)
	.db low(mesh_angle+12)
	.db low(mesh_angle+16)
	.db low(mesh_angle+28)
	.db low(mesh_angle+45)
	.db low(mesh_angle+49)
mesh_angle_ptr.hi:
	.db high(mesh_angle+0)
	.db high(mesh_angle+4)
	.db high(mesh_angle+8)
	.db high(mesh_angle+12)
	.db high(mesh_angle+16)
	.db high(mesh_angle+28)
	.db high(mesh_angle+45)
	.db high(mesh_angle+49)
mesh_radius_ptr.lo:
	.db low(mesh_radius+0)
	.db low(mesh_radius+4)
	.db low(mesh_radius+8)
	.db low(mesh_radius+12)
	.db low(mesh_radius+16)
	.db low(mesh_radius+28)
	.db low(mesh_radius+45)
	.db low(mesh_radius+49)
mesh_radius_ptr.hi:
	.db high(mesh_radius+0)
	.db high(mesh_radius+4)
	.db high(mesh_radius+8)
	.db high(mesh_radius+12)
	.db high(mesh_radius+16)
	.db high(mesh_radius+28)
	.db high(mesh_radius+45)
	.db high(mesh_radius+49)
mesh_point_count:
	.db 4,4,4,4,12,17,4,10
mesh_first:
	.db 0,4,6,5
mesh_last:
	.db 4,5,8,6
