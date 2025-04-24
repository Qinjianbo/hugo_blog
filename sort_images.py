import os
import shutil
from pathlib import Path

def sort_images(source_dir, batch_size=1000):
    # 获取源目录的Path对象
    source_path = Path(source_dir)
    
    # 获取所有图片文件
    image_extensions = ('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp')
    image_files = [f for f in source_path.glob('*') if f.suffix.lower() in image_extensions]
    
    # 计算需要创建的文件夹数量
    total_images = len(image_files)
    num_folders = (total_images + batch_size - 1) // batch_size
    
    print(f'处理文件夹：{source_dir}')
    print(f'找到 {total_images} 张图片，将分成 {num_folders} 个文件夹')
    
    # 创建文件夹并移动文件
    for i in range(num_folders):
        # 创建新文件夹
        folder_name = f'{i*batch_size+1}-{min((i+1)*batch_size, total_images)}'
        new_folder = source_path.parent / f'{source_path.name}_{folder_name}'
        new_folder.mkdir(exist_ok=True)
        
        # 移动这一批次的文件
        start_idx = i * batch_size
        end_idx = min((i + 1) * batch_size, total_images)
        
        for image_file in image_files[start_idx:end_idx]:
            shutil.move(str(image_file), str(new_folder / image_file.name))
            
        print(f'已完成文件夹 {folder_name} 的处理，包含 {end_idx-start_idx} 张图片')
    
    print('处理完成！\n')

if __name__ == '__main__':
    # 需要处理的文件夹列表
    folders_to_process = [
        r'D:\哔哩哔哩上搜集的美图色图',
        r'D:\贴吧上搜集的色图（完结）'
    ]
    
    # 依次处理每个文件夹
    for folder in folders_to_process:
        sort_images(folder) 