import torch
import torch.nn as nn

class NsoltChannelConcatenation2dLayer(nn.Module):

    def __init__(self):
        super(NsoltChannelConcatenation2dLayer, self).__init__()

    def forward(self,x):
        return x