% this script holds the main implementation of the 3 methods developed for
% a Compromised Password Checker.

load BloomFilter.mat
load trainedNaiveBayes.mat
load MinHashSignatures.mat

%% fetch the password from user input
userPassword = input('Enter your password: ', 's');

%% apply Bloom filter to check if password inputted is in compromised passwords. if so -> mark it as compromised immediatly
k = 10;
bloomfilterResult = is_in_BloomFilter(BloomFilter, userPassword, k);

if bloomfilterResult == 1
   
    disp('Your password is compromised! Better change it now.')
    return
    
end

%% if not -> apply Naive Bayes to check the probability of password being compromised

disp("--------------------------")

userPassword = convertCharsToStrings(userPassword); % convert array of chars to string

allChars_test = strjoin(userPassword, '');
chars_test = unique(char(allChars_test));

% vector that will hold the probability of each character in test password to be
% within compromised passwords
probs_compromised = zeros(length(chars_test), 1); % the number of probabilities in this array will always be equal or less than the number of unique test characters

% populate probabilities array
for i = 1:length(chars_test)
    
    % check if character is in chars_test    
    if ~ismember(chars_test(i), chars)
            
        probs_compromised(i) = [];
        continue
    
    end

    index = find(chars_test(i) == chars);
    char_count = sum(occurences_compromised(:, index)); % number of times a certain char i appears in the compromised practice set

    prob = (char_count + 1) / (sum(sum(occurences_compromised)) + length(chars));
    probs_compromised(i) = prob;
    fprintf("P(%c | compromised) = %.6f\n", chars_test(i), prob);

end


probs_strong = zeros(length(chars_test), 1);

for i = 1:length(chars_test)
    
    % check if character is in chars_test    
    if ~ismember(chars_test(i), chars)
            
        probs_strong(i) = [];
        continue
    
    end

    index = find(chars_test(i) == chars);
    char_count = sum(occurences_strong(:, index)); % number of times a certain char i appears in the compromised practice set

    prob = (char_count + 1) / (sum(sum(occurences_strong)) + length(chars));
    probs_strong(i) = prob;
    fprintf("P(%c | strong) = %.4f\n", chars_test(i), prob);

end

disp("--------------------------")

% calculation of the later probability for compromised P(compromised | test password) 
nbc_compromised = p_compromised;

for i = 1:length(probs_compromised)
    nbc_compromised = nbc_compromised * probs_compromised(i);
end

% calculation of the later probability for strong P(strong | test password) 
nbc_strong = p_strong;
for i = 1:length(probs_strong)
    nbc_strong = nbc_strong * probs_strong(i);
end

if (nbc_compromised > nbc_strong)
    disp("Your password is most likely compromised. Better change it!")
    return
end

%% and apply MinHash to see if any similarities are found

threshold = 0.5;
shingleSize = 3;
k = 200;

inputSignature = GetSignatures(userPassword, k, shingleSize);

% calculate Jaccard distances between input password and compromised
% passwords
[similarities, similars] = GetSimilarities(compromised, compromisedSignatures, inputSignature, threshold, k);


if ~isempty(similars)

    fprintf('Similar passwords found:\n');
    for i = 1:length(similars)
        fprintf('%2d. %s\n', i, similars{i}); % Display index and password
    end
    disp('Your password is not compromised, however consider changing it to something more unique.')
else

    disp('Good job, your password is not compromised and no similar passwords were found.')

end


