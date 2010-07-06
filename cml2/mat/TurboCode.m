classdef TurboCode < ChannelCode
% The methods of this class perform the operations of Binary Turbo Encoding and Decoding of a sequence of data bits or a vector of received bit Log-Likelihood Ratios (LLR),
% respectively.
       
    properties
        % CodeWord will contain multiple rows if the DataBits vector is longer than the Interleaver. If the DataLength is an integer  multiple of the
        % Interleaver length, then multiple codewords are returned one per row of the CodeWord matrix.
        
        G1          % The first binary generator matrix for the first convolutional code
        Type1=0     % Type of the first convolutional code
                    % 0 for Recursive Systematic Convolutional (RSC) codes (DEFAULT), 1 for Non-Systematic Convolutional (NSC) codes and 2 for tail-biting NSC code        
                    
        G2          % The second binary generator matrix for the second convolutional code
        Type2=0     % Type of the second convolutional code
                    % 0 for Recursive Systematic Convolutional (RSC) codes (DEFAULT), 1 for Non-Systematic Convolutional (NSC) codes and 2 for tail-biting NSC code        
        
        Interleaver % TYPE of the interleaver OR the specific interleaver pattern to be used in the Binary Turbo Code
                    % =0 Random interleaver
                    % =1 Interleaver according to the Consultative Committee for Space Data Systems (CCSDS) specifications
                    %    In this case, the number of input information bits (DataLength) for the SECOND convolutional code of the Binary Turbo Code has to be one 
                    %    of the 4 following integers: K2 = 3568, 7136, 7184 or 8920.
                    % =2 Interleaver according to the UMTS-LTE specifications
                    %    In this case, the number of input information bits (DataLength) for the SECOND convolutional code of the Binary Turbo Code has to be one 
                    %    of the 188 following integers: K2 = 40:8:512 OR 528:16:1024 OR 1056:32:2048 OR 2112:64:6144.
                    % =3 Interleaver according to the UMTS specifications
                    % If the length of this Property (Interleaver) is greater than ONE, it has to be in the form of a vector whose length is the same as the number of
                    % input information bits (DataLength) for the second convolutional code and describes the intended interleaving pattern.
                    
        IntPattern      % The vector of interleaver pattern whose integer multiple of length is obj.DataLength bits.
                    
        PuncturePatt    % The specific puncturing pattern to be used in the Binary Turbo Code for all the codeword bits EXCEPT the TAIL
                        
        TailPunc        % Specific puncturing pattern to be used in the Binary Turbo Code JUST for the TAIL
        
        DecoderType=0   % Type of the decoder to be used in the decoding process of the Binary Turbo Code
                        % =0 For linear-log-MAP algorithm (Correction function is a straght line) (DEFAULT).
                        % =1 For max-log-MAP algorithm (max*(x,y) = max(x,y) and correction function is equal to zero.)
                        % =2 For Constant-log-MAP algorithm (Correction function is a constant).
                        % =3 For log-MAP algorithm in which the correction factor is selected from small nonuniform table and interpolation.
                        % =4 For log-MAP algorithm in which the correction factor uses C function calls.
        
        Iteration=8     % Number of turbo decoding iterations
        ExtBitInf       % Extrinsic information of the code bits generated during the decoding process
    end
    
    
    properties (GetAccess='private' , SetAccess='private')
        Code1       % The first convolutional code object used in the Binary Turbo Code
        Code2       % The second convolutional code object used in the Binary Turbo Code
        N1          
        V1          % Constraint length of the first convolutional code
        N2          
        V2          % Constraint length of the second convolutional code
        NumberCodeWord  % Number of codeword
        LInterleaver    % Length of the interleaver pattern
        DataMatrix  % If obj.DataLengh>InterleaverLength, DataBits is arranged in a matrix which has InterleaverLength columns.
    end
    
    
    methods
        
        % Class Constructor: Binary generator matrices and types of both of the convolutional codes, interleaver type or pattern, puncturing
        % pattern for both codeword bits and tail bits and also, length of DataBits to be encoded must be specified.
        % The general syntax of calling the constructor of the TurboCode class is as follows:
        % obj=TurboCode(G1, G2, Interleaver, PuncturePatt, TailPunc, DataLength [, DecoderType] [,Iteration] [, Type1] [,Type2])
        
        function obj=TurboCode(G1, G2, Interleaver, PuncturePatt, TailPunc, DataLength, varargin)
            
            if (length(varargin)>=1)
                obj.DecoderType=varargin{1};
                if (length(varargin)>=2)
                    obj.Iteration=varargin{2};
                    if (length(varargin)>=3)
                        obj.Type1=varargin{3};
                        if (length(varargin)>=4)
                            obj.Type2=varargin{4};
                        end
                    end
                end
            end
            
            obj.G1=G1;
            obj.Code1=ConvCode(obj.G1, obj.Type1, obj.DecoderType);
            [obj.N1, obj.V1]=size(obj.G1); % Determining the size of the first convolutional code generator. 
            
            obj.G2=G2;
            obj.Code2=ConvCode(obj.G2, obj.Type2, obj.DecoderType);
            [obj.N2, obj.V2]=size(obj.G2);
            
            % In the future, we will allow constituent codes with different constraint lengths to be used in the Binary Turbo Codes.
            if ( obj.V1 ~= obj.V2 )
                errordlg( 'The constraint lengths of the two PCCC constituent codes must be IDENTICAL. Please choose two generator matrices for the two constituent codes with the same number of COLUMNS.', 'Constituent Code Mismatch' );
            end
            
            obj.Interleaver=Interleaver;
            obj.PuncturePatt=PuncturePatt;
            obj.TailPunc=TailPunc;
            obj.DataLength=DataLength;
            
            obj.IntPattern=InterleaverPattern(obj, obj.Interleaver);
            
            % Checking Interleaver Length against DataLength
            obj.LInterleaver = length(obj.IntPattern);
            if ( rem(obj.DataLength, obj.LInterleaver) ~=0 )
                errordlg( 'The length of data to be encoded needs to be an INTEGER multiple of the interleaver length.', 'Data Length and Interleaver Mismatch' );
            end
            
            obj.NumberCodeWord = obj.DataLength/obj.LInterleaver;
        end
            
        
        function Pattern=InterleaverPattern(obj, InterleaverType)
            % Pattern is the vector of interleaver pattern whose integer multiple of length is obj.DataLength bits.
            if (length(InterleaverType) == 1)
                
                switch InterleaverType
                    
                    case 0
                        Pattern = randperm(obj.DataLength)-1;
                    
                    case 1
                        Pattern = CreateCcsdsInterleaver(obj.DataLength);
                    
                    case 2
                        Pattern = CreateLTEInterleaver(obj.DataLength);
                        
                    case 3
                        Pattern = CreateUmtsInterleaver(obj.DataLength);
                    
                    otherwise
                        errordlg('The type of the interleaver used in the Binary Turbo Codes has to be one of the integers between 0 and 5, inclusively.', 'Invalid Interleaver Type');
                end
                
            else
                Pattern = InterleaverType;
            end
            
        end
        
        
        function [CodeWord]=Encode(obj, DataBits)
            
            if ( length(DataBits) ~= obj.DataLength )
                errordlg( 'The input DataBits to be encoded by this object has to be a binary vector of DataLength bits length.', 'Invalid DataBits Length for This Object' );
            end
            
            obj.DataBits=DataBits;
            obj.DataMatrix = reshape( obj.DataBits, obj.LInterleaver, obj.NumberCodeWord )';
                        
            for i=1:obj.NumberCodeWord
                
                % Encoding in Parallel
                T=obj.DataMatrix(i,:);
                UpperOutput = obj.Code1.Encode (T);
                LowerOutput = obj.Code2.Encode (T(obj.IntPattern+1));
                                
                % Converting Coded Outputs to Matrices (each row is from one row of the generator)
                UpperReshaped = reshape( UpperOutput, obj.N1, length(UpperOutput)/obj.N1 );
                LowerReshaped = reshape( LowerOutput, obj.N2, length(LowerOutput)/obj.N2 );
                
                % Parallel Concatenation of CodeWord Parts
                UnPuncturedWord = [UpperReshaped
                    LowerReshaped];
                
                % Puncture function deletes bits at the output of encoder according to the specified puncutring pattern.
                CodeWord(i,:) = Puncture(UnPuncturedWord, obj.PuncturePatt, obj.TailPunc);
            end
            
            obj.CodeWord=CodeWord;
        end
        
        % ReceivedLLR could have multiple rows if DataBits is longer than IntPattern.
        % UpperInU: OPTIONAL a priori information about systematic data bits
        % The syntax of calling this method is as follows: [EstData, ExtBitInf]=Decode(obj, ReceivedLLR [, UpperInU])
        
        function [EstData, ExtBitInf]=Decode(obj, ReceivedLLR, varargin)
                        
            obj.ReceivedLLR=ReceivedLLR;
            
            % Initializing Error Counter
            NErrors = zeros(obj.Iteration, 1);
            
            if (length(varargin) >= 1)
                UpperInU = varargin{1};
            else
                UpperInU = zeros( obj.NumberCodeWord, obj.DataLength/obj.NumberCodeWord );
            end            
            
            % Loop Over Each ReceivedLLR Frame
            for i=1:obj.NumberCodeWord
                % Depuncture and Split Each ReceivedLLR Frame
                DepuncOutput = Depuncture(obj.ReceivedLLR(i,:), obj.PuncturePatt, obj.TailPunc);
                UpperInC = reshape( DepuncOutput(1:obj.N1,:), 1, obj.N1*length(DepuncOutput) );
                LowerInC = reshape( DepuncOutput(obj.N1+1:obj.N1+obj.N2,:), 1, obj.N2*length(DepuncOutput) );
                
                % Decoding Process
                for TurboIter=1:obj.Iteration
                    % Pass Through Upper Decoder
                    % UpperOutputU and UpperOutputC are the LLRs of the DataBits and Code Bits.
                    [Useless UpperOutputU UpperOutputC] = obj.Code1.Decode( UpperInC, UpperInU(i,:) );
                    
                    % Interleaving and Extracting Extrinsic Information
                    T=UpperOutputU-UpperInU(i,:);
                    LowerInU = T(obj.IntPattern+1);
                    
                    % Pass Through Lower Decoder
                    [Useless LowerOutputU LowerOutputC] = obj.Code2.Decode( LowerInC, LowerInU );
                    
                    % Counting the Number of Eerrors
                    Temp1(obj.IntPattern+1)=(sign(LowerOutputU)+1)/2;
                    DetectedData(i,:) = Temp1;
                    ErrorPosition = xor( DetectedData(i,:), obj.DataMatrix(i,:) );
                    TNError = sum(ErrorPosition);
                    
                    % Exit If All Errors Are Corrected                    
                    if (TNError==0)
                        break;
                    else
                        NErrors(TurboIter) = TNError+NErrors(TurboIter);
                        % Interleave and Extract Extrinsic Information
                        Temp2(obj.IntPattern+1)=LowerOutputU-LowerInU;
                        UpperInU(i,:)=Temp2;
                    end
                    
                end
                
                % Combining OutputC, Puncturing It and Converting It to Matrices (each row is from one row of the generator).
                UpperReshaped = reshape( UpperOutputC, obj.N1, length(UpperOutputC)/obj.N1 );
                LowerReshaped = reshape( LowerOutputC, obj.N2, length(LowerOutputC)/obj.N2 );
                
                % Parallel Concatenation
                UnPuncturedWord = [UpperReshaped
                    LowerReshaped];
                
                % Repuncturing (ExtBitInf is the extrinsic information of the code bits.)
                ExtBitInf(i,:) = Puncture( UnPuncturedWord, obj.PuncturePatt, obj.TailPunc );
            end
            
            EstData = reshape(DetectedData', 1, obj.DataLength);
            obj.EstBits=EstData;
            obj.ExtBitInf=ExtBitInf;
        end
    end
end