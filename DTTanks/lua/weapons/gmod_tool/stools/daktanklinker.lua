 
TOOL.Category = "DakTek Tank Edition"
TOOL.Name = "#Tool.daktanklinker.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
TOOL.LastLeftClick = CurTime()
TOOL.LastRightClick = CurTime()

if (CLIENT) then
language.Add( "Tool.daktanklinker.listname", "DakTek Tank Edition Linker" )
language.Add( "Tool.daktanklinker.name", "DakTek Tank Edition Linker" )
language.Add( "Tool.daktanklinker.desc", "Links motors to fuel and autoloader clips to autoloaders." )
language.Add( "Tool.daktanklinker.0", "Left click to select the motor, AL clip, or turret motor. Right click on the fuel, gun, or turret control." )
end
--TOOL.ClientConVar[ "myparameter" ] = "fubar"
 
function TOOL:LeftClick( trace )
	if CurTime()>self.LastLeftClick then
		local Target = trace.Entity
		if(string.Explode("_",Target:GetClass(),false)[1] == "dak") then
			if Target:GetClass() == "dak_temotor" or Target:GetClass() == "dak_teautoloadingmodule" or Target:GetClass() == "dak_turretmotor" then
				self.Ent1 = Target
				if (CLIENT) or (game.SinglePlayer()) then
					self:GetOwner():EmitSound("/items/ammocrate_open.wav")
					self:GetOwner():ChatPrint("Entity selected.")
				end
			else
				self:GetOwner():EmitSound("items/medshotno1.wav")
				self:GetOwner():ChatPrint("Entity cannot be linked to anything.")
			end
		end
	self.LastLeftClick = CurTime()
	end
end
 
function TOOL:RightClick( trace )
	if CurTime()>self.LastRightClick then
		local Target = trace.Entity
		if not(self.Ent1==NULL) then
			if(Target:GetClass() == "dak_tefuel") then
				if self.Ent1:GetClass() == "dak_temotor" then
					self.Ent2 = Target
					self.Ent1.DakFuel = self.Ent2
					if (CLIENT) or (game.SinglePlayer()) then
						self:GetOwner():EmitSound("/items/ammocrate_close.wav")
						self:GetOwner():ChatPrint("Engine linked.")
					end
				else
					self:GetOwner():EmitSound("items/medshotno1.wav")
					self:GetOwner():ChatPrint("This is not a valid link.")
				end
			end	
			if(Target:GetClass() == "dak_teautogun") then
				if self.Ent1:GetClass() == "dak_teautoloadingmodule" then
					self.Ent2 = Target
					self.Ent1.DakGun = self.Ent2
					if (CLIENT) or (game.SinglePlayer()) then
						self:GetOwner():EmitSound("/items/ammocrate_close.wav")
						self:GetOwner():ChatPrint("Module linked.")
					end
				else
					self:GetOwner():EmitSound("items/medshotno1.wav")
					self:GetOwner():ChatPrint("This is not a valid link.")
				end
			end
			if(Target:GetClass() == "dak_turretcontrol") then
				if self.Ent1:GetClass() == "dak_turretmotor" then
					self.Ent2 = Target
					self.Ent2.DakTurretMotor = self.Ent1
					if (CLIENT) or (game.SinglePlayer()) then
						self:GetOwner():EmitSound("/items/ammocrate_close.wav")
						self:GetOwner():ChatPrint("Turret motor linked.")
					end
				else
					self:GetOwner():EmitSound("items/medshotno1.wav")
					self:GetOwner():ChatPrint("This is not a valid link.")
				end
			end	
		end
	self.LastRightClick = CurTime()
	end
end
 
function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "DakTek Tank Edition Linker", Description = "Links motors to fuel" })

	local DLabel = vgui.Create( "DLabel", panel )
	DLabel:SetPos( 17, 50 )
	DLabel:SetAutoStretchVertical( true )
	DLabel:SetText( "This tool just links motors to fuel, clips to autoloaders, and turret motors to turret controls. Ammo is automatically found on the contraption by the gun." )
	DLabel:SetTextColor(Color(0,0,0,255))
	DLabel:SetWide( 225 )
	DLabel:SetWrap( true )
end
 
