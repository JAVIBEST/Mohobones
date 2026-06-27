-- ReadBoneStructure.lua
-- Script para Moho Pro 14: Leer y crear estructura de huesos jerárquica
-- Autor: Moho Script Generator
-- Descripción: Lee huesos existentes, crea nuevos huesos en estructura jerárquica
-- con 5 huesos centrales y 3 huesos de alfiler, y establece relaciones

local moho = MOHO
local doc = moho.document

-- ============================================
-- TABLA DE ESTRUCTURA DE HUESOS
-- ============================================

local BoneStructure = {
  centralBones = {
    {name = "Bone_Central_1", parent = nil},
    {name = "Bone_Central_2", parent = "Bone_Central_1"},
    {name = "Bone_Central_3", parent = "Bone_Central_2"},
    {name = "Bone_Central_4", parent = "Bone_Central_3"},
    {name = "Bone_Central_5", parent = "Bone_Central_4"}
  },
  pinBones = {
    {name = "Pin_Bone_1", parent = "Bone_Central_2", target = nil},
    {name = "Pin_Bone_2", parent = "Bone_Central_3", target = nil},
    {name = "Pin_Bone_3", parent = "Bone_Central_4", target = nil}
  }
}

-- ============================================
-- FUNCIÓN: Obtener índice de hueso por nombre
-- ============================================

function GetBoneIndexByName(layer, boneName)
  if not layer or not layer.bones then
    return nil
  end
  
  for i = 0, layer.bones:Count() - 1 do
    local bone = layer.bones:Item(i)
    if bone.name == boneName then
      return i
    end
  end
  
  return nil
end

-- ============================================
-- FUNCIÓN: Imprimir estructura actual
-- ============================================

function PrintCurrentBoneStructure()
  print("\n========== ESTRUCTURA ACTUAL DE HUESOS ==========")
  
  if not doc or not doc.currentLayer then
    print("ERROR: No hay capa activa")
    return
  end
  
  local layer = doc.currentLayer
  
  if not layer.bones or layer.bones:Count() == 0 then
    print("No hay huesos en la capa actual")
    return
  end
  
  print("Total de huesos: " .. layer.bones:Count())
  print("")
  
  for i = 0, layer.bones:Count() - 1 do
    local bone = layer.bones:Item(i)
    local parentIndex = bone.parent
    local parentName = "NINGUNO (Raíz)"
    
    if parentIndex >= 0 and parentIndex < layer.bones:Count() then
      local parentBone = layer.bones:Item(parentIndex)
      parentName = parentBone.name
    end
    
    print(string.format("  [%d] %s (Padre: %s)", i, bone.name, parentName))
  end
  
  print("================================================\n")
end

-- ============================================
-- FUNCIÓN: Crear hueso
-- ============================================

function CreateBone(layer, boneName, parentIndex)
  if not layer or not layer.bones then
    print("ERROR: Capa inválida")
    return nil
  end
  
  -- Crear nuevo hueso
  local newBone = MOHO:GetBone()
  newBone.name = boneName
  newBone.parent = parentIndex or -1
  
  -- Agregar a la capa
  layer.bones:InsertBone(layer.bones:Count(), newBone)
  
  print("✓ Hueso creado: " .. boneName .. " (Padre: " .. (parentIndex or -1) .. ")")
  
  return layer.bones:Count() - 1
end

-- ============================================
-- FUNCIÓN: Crear estructura jerárquica
-- ============================================

function CreateBoneHierarchy()
  print("\n========== CREANDO ESTRUCTURA DE HUESOS ==========\n")
  
  local layer = doc.currentLayer
  if not layer or not layer.bones then
    print("ERROR: No hay capa activa")
    return false
  end
  
  local boneIndexMap = {}
  
  -- CREAR HUESOS CENTRALES
  print("1. Creando huesos centrales en eje vertical...")
  
  for i, centralBone in ipairs(BoneStructure.centralBones) do
    local parentIdx = -1
    
    if centralBone.parent then
      parentIdx = boneIndexMap[centralBone.parent] or -1
    end
    
    local newIndex = CreateBone(layer, centralBone.name, parentIdx)
    boneIndexMap[centralBone.name] = newIndex
  end
  
  print("\n2. Creando huesos de alfiler (Pin Bones)...")
  
  -- CREAR HUESOS DE ALFILER
  for i, pinBone in ipairs(BoneStructure.pinBones) do
    local parentIdx = -1
    
    if pinBone.parent then
      parentIdx = boneIndexMap[pinBone.parent] or -1
    end
    
    local newIndex = CreateBone(layer, pinBone.name, parentIdx)
    boneIndexMap[pinBone.name] = newIndex
  end
  
  print("\n================================================")
  print("✓ Estructura de huesos creada exitosamente")
  print("================================================\n")
  
  return true
end

-- ============================================
-- FUNCIÓN: Exportar estructura en JSON
-- ============================================

function ExportBoneStructureJSON()
  print("\n========== EXPORTANDO ESTRUCTURA ==========\n")
  
  local layer = doc.currentLayer
  if not layer or not layer.bones then
    print("ERROR: No hay capa activa")
    return
  end
  
  local jsonContent = "{\n  \"bones\": [\n"
  
  for i = 0, layer.bones:Count() - 1 do
    local bone = layer.bones:Item(i)
    local parentName = "null"
    
    if bone.parent >= 0 and bone.parent < layer.bones:Count() then
      local parentBone = layer.bones:Item(bone.parent)
      parentName = "\"" .. parentBone.name .. "\""
    end
    
    jsonContent = jsonContent .. string.format(
      "    {\"index\": %d, \"name\": \"%s\", \"parent\": %s}",
      i, bone.name, parentName
    )
    
    if i < layer.bones:Count() - 1 then
      jsonContent = jsonContent .. ",\n"
    else
      jsonContent = jsonContent .. "\n"
    end
  end
  
  jsonContent = jsonContent .. "  ]\n}\n"
  
  print("JSON Structure:")
  print(jsonContent)
  
  return jsonContent
end

-- ============================================
-- FUNCIÓN: Mostrar menú principal
-- ============================================

function ShowMainMenu()
  print("\n╔════════════════════════════════════════╗")
  print("║     GESTOR DE HUESOS - MOHO PRO 14    ║")
  print("╚════════════════════════════════════════╝\n")
  
  print("SCRIPT EJECUTADO CORRECTAMENTE")
  print("")
  print("1. Ver estructura actual de huesos")
  print("2. Crear nueva estructura (5 huesos + 3 pines)")
  print("3. Exportar estructura en JSON")
  print("4. Salir\n")
end

-- ============================================
-- MAIN - EJECUCIÓN PRINCIPAL
-- ============================================

function Main()
  -- Verificar que hay un documento abierto
  if not doc or not doc.currentLayer then
    print("ERROR: Por favor, abre un proyecto Moho primero")
    return
  end
  
  ShowMainMenu()
  
  print("Ejecutando automáticamente...\n")
  
  PrintCurrentBoneStructure()
  
  if CreateBoneHierarchy() then
    PrintCurrentBoneStructure()
    ExportBoneStructureJSON()
  end
  
  print("PROCESO COMPLETADO")
end

-- Ejecutar
Main()
