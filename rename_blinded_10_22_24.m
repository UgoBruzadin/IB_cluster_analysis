
% Read the blinded table
blindedTable = readtable("Z://Triangulation//Reed//IB//Subjects//Subjects//blinded_table_10_18_2024.xlsx");

% Get all files in the current directory and subdirectories
all_files_set = dir(fullfile(pwd, '*.set'));
all_files_fdt = dir(fullfile(pwd, '*.fdt'));


all_files = [all_files_set; all_files_fdt];

all_files = dir()

current_folder = pwd;
mkdir("BLINDED")
cd("BLINDED")
blinded_folder = pwd;
cd(current_folder);
mkdir("NOTBLINDED")
cd("NOTBLINDED")
notblinded_folder = pwd;
cd(current_folder);
mkdir("OTHER")
cd("OTHER")
other_folder = pwd;
cd(current_folder);

% Loop through each file
for k = 1:length(all_files)
    current_file = all_files(k);
    [folder, base_name, ext] = fileparts(current_file.name);

    %if contains(base_name, 'Blinded')
    %    continue;
    %end
    try
    file_split = split(base_name,['_']);
    file_split2 = split(file_split(3),'.');
    file_number = strcat(file_split(1),'_',file_split(2),'_',file_split(3));
    catch
        continue
    end
    subject_number = file_number;
    % % Extract the subject number (assuming it's in the format IB_sub_X)
    % subject_match = regexp(base_name, 'IB_sub_\d+', 'match');
    % if isempty(subject_match)
    %     continue; % Skip files without subject number format IB_sub_X
    % end
    % subject_number = subject_match{1};

    % Find the corresponding row in blindedTable for this subject
    subject_row = strcmp(blindedTable.SubjectNumber, subject_number);
    
    if any(subject_row)
        % Determine if the subject is blinded or not
        is_blinded = blindedTable.Phase1_Blinded(subject_row);
        
        if is_blinded == 1
            blindedtext = '_Blinded';
            new_folder = blinded_folder;
        else
            blindedtext = '_NotBlinded';
            new_folder = notblinded_folder;
        end

        % if strfind(base_name(end),'_')
        %     new_base_name = [base_name(1:end-1)];
        % end

        %pos = strfind(base_name, blindedtext);
        %if isempty(pos)
        %    continue
        %end

        %new_base_name = [base_name(1:pos-1)];

        % Construct the new file name
        new_base_name = [base_name, '_', blindedtext];
        %new_file_name = fullfile(new_folder, [new_base_name, ext]);
        
        
        % Rename the file
        try
            new_file_name = fullfile(new_folder, [new_base_name, ext]);
            copyfile(fullfile(current_file.folder, current_file.name), new_file_name);
            %movefile(fullfile(current_file.folder, current_file.name), new_file_name, "f");
        catch
            new_file_name = fullfile(other_folder, [new_base_name, ext]);
            copyfile(fullfile(current_file.folder, current_file.name), new_file_name);
        end
        
        % Print the rename action
        fprintf('Renamed: %s -> %s\n', fullfile(current_file.folder, current_file.name), new_file_name);
    else
        % No matching subject number found in blindedTable
        fprintf('No matching subject number for file: %s\n', fullfile(current_file.folder, current_file.name));
    end
end

disp('Renaming completed.');
