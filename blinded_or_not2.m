% Define the list of .mat files (replace with your actual file paths)
%matFiles = {'/path/to/Subject 1/file1.mat', '/path/to/Subject 2/file2.mat', '/path/to/Subject 3/file3.mat'}; 
[matFiles] = GetAllDirFiles_any(pwd, '.mat');

% Initialize an empty table
blindedTable = [];

error_log = fullfile(pwd, 'error_log_data.txt');

% Loop through each .mat file
for fileIdx = 1:length(matFiles)
    %try
        % Load the current .mat file
        subjectNumber = matFiles(fileIdx).name(1:end-4);
        %subjectNumber = subjectNumber(2:end);  % Assuming format like '/Subject X/'
        cd(matFiles(fileIdx).folder)
        
        data = load(matFiles(fileIdx).name);
        if ~isfield(data, 'session')
            continue
        end
        
        % Check for Phase 1 answers (n1, n2, n4, n5, n6)
        if ~isempty(data.session.Phase(1).postPhaseAns)
            if isfield(data.session.Phase(1), 'postPhaseAns')
                phase1Answers = data.session.Phase(1).postPhaseAns;
    
                % Check if n3(2) and n3(5) frequency and confidence are 3 or above
                n3_checks = [
                    %phase1Answers.n3(2).frequency >= 3, phase1Answers.n3(5).frequency >= 3; ...
                    phase1Answers.n3(2).confidance >= 3, ...
                    
                    phase1Answers.n3(5).confidance >= 3];
    
                % Check open ended answers (n1, n2, n4, n5, n6) for synonyms (unchanged)
                % ... (rest of your code for checking open ended answers)
    
                % Combine checks (n3 checks and open ended answers - modify if needed)
                blinded = ~any(n3_checks);  % Assuming inattention if not all n3 checks are met
    
                % Add data to table (SubjectNumber, Phase 1 Blinded)
                blindedTable = [blindedTable; {subjectNumber, blinded}];
                % ... (rest of your code)
            %end
            else
                warning(['Data for Phase 1 missing in file: ', matFiles(fileIdx).name]);
            end
        end
    %catch ME
        % Log any errors that occur with a timestamp
    %    fid = fopen(error_log, 'a');
    %    fprintf(fid, '[%s] Error processing %s: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), matFiles(fileIdx).name, ME.message);
    %    fclose(fid);
    %end
end
cd ..
% Define table column names
colNames = {'SubjectNumber', 'Phase1_Blinded'};

% Convert table to a more readable format (optional)
blindedTable = cell2table(blindedTable, 'VariableNames', colNames);

t = datetime();
[y,m,d] = ymd(t);

% Display and save the table
disp(blindedTable);
writetable(blockAccuracyTable,sprintf('combined_Block_accuracy_speed_table2_%d_%d_%d.xlsx',m,d,y))
writetable(blindedTable,sprintf('blinded_table_%d_%d_%d.xlsx',m,d,y)');
%save('blinded_table.mat', 'blindedTable');