classdef ChannelCode < handle
% ChannelCode is an abstract superclass for all channel code subclasses. It has three generec methodes
% of Encode, Decode, and ErrorCount.
%
% ChannelCode Properties:
%   DataBits        - Row vector of data bits to be coded
%   DataLength      - Length of DataBits vector
%   Codeword        - Generated row vector codeword of DataBits
%   CodewordLength  - Length of each Codeword
%   ReceivedLLR     - Received vector of bit Log-Likelihood-Ratio (LLR) for the received data (Codeword) to be decoded
%   EstBits         - Row vector of decoded bits of ReceivedLLR
%   Rate            - Code rate (R=k/n)
%   NumError        - The number of errors calculated by comparing DataBits and EstBits
%
% ChannelCode Methods:
%   Encode          - Encode methode
%   Decode          - Decode method
%   ErrorCount      - Counting the errors made between the input and ouput of the Encode and Decode methods, respectively.

    properties
        DataBits        % Row vector of data bits to be coded
        DataLength      % Length of DataBits vector
        CodewordLength  % Length of each Codeword
        ReceivedLLR     % Received vector of bit Log-Likelihood-Ratio (LLR) for the received data (Codeword) to be decoded
        Rate            % Code rate (R=k/n)
    end
    
    properties(SetAccess = protected)
        Codeword        % Generated row vector codeword of DataBits
        EstBits         % Row vector of decoded bits of ReceivedLLR
        NumError        % The number of errors calculated by comparing DataBits and EstBits
    end
    
    methods
        function [Codeword]=Encode(obj, DataBits)
%       This is the encode method.            
        end
        function [EstData]=Decode(obj, ReceivedLLR)
%       This is the decode method.            
        end
        function [NumBitError] = ErrorCount(obj, ReceivedLLR, varargin)
%       This is the methode responsible for counting the errors made between the input and ouput of the Encode and Decode methods, respectively.
            EstBits = obj.Decode(ReceivedLLR, varargin{:});
            NumBitError = sum( EstBits ~= obj.DataBits );
        end
    end    
end