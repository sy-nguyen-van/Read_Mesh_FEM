# -*- coding: utf-8 -*-
"""
Created on Thu Mar 27 11:53:04 2025

@author: snv22002
"""

import numpy as np
import pandas as pd
# ====================== Import-Abaqus-library ==============================
def read_inp_mesh(file_path):
    nodes = {}  # Dictionary to store node ID -> coordinates
    elements = {}  # Dictionary to store element ID -> node connectivity
    current_section = None
    
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            # Skip empty lines or comments
            if not line or line.startswith('**'):
                continue
            
            # Identify section headers
            if line.startswith('*NODE') or line.startswith('*Node'):
                current_section = 'nodes'
                continue
            elif line.startswith('*ELEMENT') or line.startswith('*Element'):
                current_section = 'elements'
                continue
            elif line.startswith('*'):
                current_section = None  # Reset when a new section starts
                continue
            
            # Parse data based on current section
            if current_section == 'nodes':
                try:
                    parts = [float(x) for x in line.split(',')]
                    node_id = int(parts[0])
                    coords = parts[1:]  # x, y, z coordinates
                    nodes[node_id] = coords
                except (ValueError, IndexError):
                    continue
            
            elif current_section == 'elements':
                try:
                    parts = [int(x) for x in line.split(',')]
                    element_id = parts[0]
                    connectivity = parts[1:]  # Connected node IDs
                    elements[element_id] = connectivity
                except (ValueError, IndexError):
                    continue
    
    return nodes, elements
# ============================
def save_to_csv(nodes, elements, Name_Sub_Model):
    node_file = Name_Sub_Model +'_Nodes.csv'
    element_file = Name_Sub_Model + '_Elements.csv'
    # Convert nodes to DataFrame
    node_data = {
        'Node_ID': list(nodes.keys()),
        'X': [coords[0] for coords in nodes.values()],
        'Y': [coords[1] for coords in nodes.values()],
        'Z': [coords[2] if len(coords) > 2 else 0.0 for coords in nodes.values()]  # Default Z to 0 if 2D
    }
    node_df = pd.DataFrame(node_data)
    node_df.to_csv(node_file, index=False)
    print(f"Saved nodes to {node_file}")

    # Convert elements to DataFrame
    max_nodes = max(len(conn) for conn in elements.values())  # Find max number of nodes per element
    element_data = {'Element_ID': list(elements.keys())}
    for i in range(max_nodes):
        element_data[f'Node_{i+1}'] = [conn[i] if i < len(conn) else None for conn in elements.values()]
    element_df = pd.DataFrame(element_data)
    element_df.to_csv(element_file, index=False)
    print(f"Saved elements to {element_file}")
# ====================== Data-Preparation ==============================
Name_Sub_Model = 'L_bracket_45_45_15_3'
file_name = Name_Sub_Model + '.inp'
nodes, elements = read_inp_mesh(file_name)
save_to_csv(nodes, elements, Name_Sub_Model)


