function output = fcn_Order2BuildingBlockTypeII( input, mtxW, mtxU, ps, pa, nshift ) %#codegen
% FCN_NSOLTX_SUPEXT_TYPE2
%
% SVN identifier:
% $Id: fcn_Order2BuildingBlockTypeII.m 683 2015-05-29 08:22:13Z sho $
%
% Requirements: MATLAB R2013b
%
% Copyright (c) 2014-2015, Shogo MURAMATSU
%
% All rights reserved.
%
% Contact address: Shogo MURAMATSU,
%                Faculty of Engineering, Niigata University,
%                8050 2-no-cho Ikarashi, Nishi-ku,
%                Niigata, 950-2181, JAPAN
%
% LinedIn: http://www.linkedin.com/pub/shogo-muramatsu/4b/b08/627
%
persistent h;
if isempty(h)
    h = saivdr.dictionary.nsoltx.mexsrcs.Order2BuildingBlockTypeII();
end
P = ps + pa;
p1 = floor(P/2);
p2 = ceil(P/2);
output = step(h, input, eye(p2), eye(p2), zeros(floor(P/4),1), mtxW, mtxU, zeros(floor(P/4),1), nshift);
end
