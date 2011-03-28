classdef AWGN < Channel
    
    properties
        DataIndex           % DataIndex row vector to be modulated.
        
        ModulatedSignal     % K by N matrix containing modulated signal (K is the dimensionality of the signal space and N is the number of symbols.)
                            % Each symbol is composed of LOG2(Modulation.Order) bits.
        RecievedSignal      % K by N REAL matrix of received signal at the output of matched filter to be demodulated.
        SymbolLikelihood    % Order by N real matrix of SYMBOL likelihoods (It specifies the likelihood of each of N received symbols to each of the Order
                            % possible points in the signal constellation.)
        
        EsN0                % Ratio of Es/N0 for the realization of the channel (in Linear Units NOT dB).
        Variance            % Noise variance.
        UpperSymbolBoundValue % Value of union bound on average symbol error probability.
    end
    
    
    methods( Static )
        function UpperSymbolBoundValue = UnionBoundSymbol( SignalSet, EsN0, SignalProb )
            % EsN0 is in linear (Es = 1).
            Distance = AWGN.GetSignalDistance(SignalSet);
            UpperSymbolBoundValue = AWGN.GetUnionBoundSymbol(Distance, EsN0, SignalProb);
        end
        
        function Distance = GetSignalDistance(SignalSet)
            NoSignals = size( SignalSet, 2);    % Determine the number of signals.
            Distance = zeros(NoSignals);
            % Calculate the distance between each signal and the rest of the signals.
            % Upper triangular part of Distance has the distances of signals with each other. It is a symmetric matrix.
            for m = 1:NoSignals-1
                SignalDifference = repmat(SignalSet(:,m), [1 NoSignals-m]) - SignalSet(:, m+1:end);
                Distance(m, m+1:end) = sqrt( sum( abs(SignalDifference).^2 ) );     % Sum over columns of matrix.
            end
        end
        
        function UpperSymbolBoundValue = GetUnionBoundSymbol(Distance, EsN0, SignalProb)
            NoSignals = size( Distance, 2);    % Determine the number of signals.
            % Calculate Q function for upper triangular part.
            QValuesT = 0.5 * (1 - erf( sqrt(EsN0)*Distance / 2 ));
            
            % Use the symmetry to get the Q function valued for upper triangular part.
            QValuesUp = triu(QValuesT, 1);
            QValues = QValuesUp.' + QValuesUp;
            
            % Calculate conditional symbol error bound.
            CondSymbolErrorBound = sum(QValues);
            % Calculate the union bound on average symbol error probability.
            if (nargin<3 || isempty(SignalProb))
                UpperSymbolBoundValue = sum(CondSymbolErrorBound) / NoSignals;
            else
                UpperSymbolBoundValue = sum( CondSymbolErrorBound .* SignalProb );
            end
        end
    end
    
    
    methods
        function obj = AWGN( ModulationObj, EsN0 )
            obj.ModulationObj = ModulationObj;
            obj.EsN0 = EsN0;
            % Determine the noise variance.
            obj.Variance = 1/(2*EsN0);
            obj.UpperSymbolBoundValue = AWGN.UnionBoundSymbol( ModulationObj.SignalSet, EsN0, ModulationObj.SignalProb );
        end
        
        
        function SymbolLikelihood = ChannelUse(obj, SymbolIndex, EsN0)
            if (nargin>=3 && ~isempty(EsN0))
                if (obj.EsN0<0)
                    error('In order to demodulate RecievedSignal, EsN0 of the channel has to be specified in LINEAR units.');
                end
                obj.EsN0 = EsN0;
                obj.Variance = 1/(2*EsN0);
            end
            ModulatedSignal=Modulate(obj, SymbolIndex);
            RecievedSignal = PassToChannel(obj, ModulatedSignal);
            SymbolLikelihood = Demodulate( obj, RecievedSignal );
        end
        
        
        function ModulatedSignal=Modulate(obj, DataIndex)
        % Modulate Method.
            obj.DataIndex = DataIndex;
            ModulatedSignal=obj.ModulationObj.SignalSet(:, DataIndex);
            obj.ModulatedSignal=ModulatedSignal;
        end
        
        
        function SymbolLikelihood = Demodulate( obj, RecievedSignal, EsN0 )
        % Demodulate Method: SymbolLikelihood = Demodulate( RecievedSignal [,EsN0] )
            obj.RecievedSignal=RecievedSignal;
            if (nargin>=3 && ~isempty(EsN0))
                if (obj.EsN0<0)
                    error('In order to demodulate RecievedSignal, EsN0 of the channel has to be specified in LINEAR units.');
                end
                obj.EsN0 = EsN0;
                obj.Variance = 1/(2*EsN0);
            end
            
            SymbolLikelihood = VectorDemod(obj.RecievedSignal, obj.ModulationObj.SignalSet, obj.EsN0);
            obj.SymbolLikelihood = SymbolLikelihood;
        end
        
        
        function RecievedSignal = PassToChannel(obj, ModulatedSignal)
            Noise = sqrt(obj.Variance) * randn(size(obj.ModulationObj.SignalSet,1) , size(ModulatedSignal,2));
            RecievedSignal = Noise + ModulatedSignal;
            obj.RecievedSignal = RecievedSignal;
        end
    end
    
end
    