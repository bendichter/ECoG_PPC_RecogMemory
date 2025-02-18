function plotFigure3(data1,data2,data3,data4,data5,data6,opts)

inkscapePath='/Applications/Inkscape.app/Contents/Resources/bin/inkscape';
SupPlotPath = ['~/Google ','Drive/Research/ECoG ','Manuscript/ECoG ', 'Manuscript Figures/supplement/'];
fontSize  = 16;

temp = load('../Results/ERP_Data/group/allERPsGroupstimLocksubAmpnonLPCleasL1TvalCh10.mat');
chanLocs    =  temp.data.MNILocs;
cortex{1}   =  temp.data.lMNIcortex;

% dependencies
%   scatterPlotWithErrors.m

colors      = [];
colors{1}  = [0.9 0.2 0.2];
colors{2}  = [0.1 0.5 0.8];
colors{3}   = [0.2 0.6 0.3];
colors{4}    = 0.1*[1 1 1];

hem_str     = {'l','r'};
view{1}     = [310,30];

ticks = [0.5:0.1:0.9];
nBoot1 = data1.classificationParams.nBoots;
nBoot2 = data2.classificationParams.nBoots;

% channel selection
Subjchans   = ismember(data1.subjChans,opts.subjects);
chans       = double(ismember(data1.ROIid.*Subjchans,opts.ROIs));

ylims = opts.ylims;
xlims = opts.xlims;

N = sum(chans);
nROIs = numel(opts.ROIs);
nChanPerROI =[];
if opts.ROIids
    cols = zeros(N,3);
    cnt = 1;
    for rr = opts.ROIs
        
        roiChans = chans & (data1.ROIid==rr); n = sum(roiChans);
        nChanPerROI = [nChanPerROI sum(roiChans)];
        chans(cnt:(n+cnt-1)) = find(roiChans);
        cols(cnt:(n+cnt-1),:)= repmat(colors{rr},n,1);
        
        cnt = cnt + n;
    end
    chans = chans(1:N);
else
    cols = repmat(colors{4},[N,1]);
end

M1 =[];
M1(:,1) = data1.mBAC(chans);
M1(:,2) = data1.sdBAC(chans)/sqrt(nBoot1-1);
% XX      = permute(squeeze(data1.perf),[2 1 3]);
% YY      =reshape(XX,[],100); YY(isnan(YY(:,1)),:)=[];
% M1(:,2:3)=quantile(YY(chans,:),[0.025 0.975],2);

M2 =[];
M2(:,1) = data2.mBAC(chans);
M2(:,2) = data2.sdBAC(chans)/sqrt(nBoot2-1);
% XX      = permute(squeeze(data2.perf),[2 1 3]);
% YY      =reshape(XX,[],100); YY(isnan(YY(:,1)),:)=[];
% M2(:,2:3)=quantile(YY(chans,:),[0.025 0.975],2);

%% scatter plot and bar graphs of accuracy
if 0
    % plot M1 vs M2
    f = figure(1); clf;
    figW = 800;
    figH = 600;
    set(gcf,'position',[-800 200,figW,figH],'PaperPositionMode','auto','color','w')
    ha = tight_subplot(2,2);
    
    scatterW = 0.5;
    scatterH = scatterW*figW/figH;
    hBarW    = scatterW;  hBarH = 0.1;
    vBarW    = hBarH;     vBarH = scatterH;
    
    xPos= [0.1]; xPos = [xPos xPos+vBarW+0.01];
    yPos= [0.15]; yPos = [yPos yPos+hBarH+0.01];
    
    set(ha(1),'position',[xPos(2) yPos(2) scatterW scatterH]) %scatter plot
    set(ha(2),'position',[xPos(2) yPos(1) hBarW hBarH]) % horizontal bar plot
    set(ha(3),'position',[xPos(1) yPos(2) vBarW vBarH]) % vertical bar plot
    set(ha(4),'visible','off');
    
    % panel ID
    axes('position', [0.001 0.95 0.3 0.05]); xlim([0 1]); ylim([0 1])
    text(0.05,0.45,' a ','fontsize',28)
    set(gca,'visible','off')
    
    % axes labels
    axes('position',[xPos(2),yPos(1)-0.1,hBarW,0.1])
    text(0.5,0.4,'Stim-Locked Accuracy','fontsize',18,...
        'VerticalAlignment','middle','horizontalAlignment','center')
    axis off
    
    axes('position',[xPos(1)-0.1,yPos(2),xPos(1),vBarH])
    text(0.2,0.5,'Resp-Locked Accuracy','fontsize',18,'rotation',90, ...
        'VerticalAlignment','middle','horizontalAlignment','center')
    axis off
    
    axes(ha(1)); hold on;
    scatterPlotWithErrors(M1,M2, cols, [xlims; ylims], [0.5 0.5 1]);
    set(gca,'yTick',ticks,'xTick',ticks)
    set(gca,'yTicklabel','','xTicklabel','')
    
    %
    axes(ha(2)); hold on;
    
    cnt = 1;
    for r = 1:nROIs
        roiChans = cnt:nChanPerROI(r)+cnt-1;
        
        ym = mean([M1(roiChans,1)]);
        ys = std([M1(roiChans,1)])/sqrt(nChanPerROI(r)-1);
        
        barh(r,ym,'FaceColor',colors{r},'edgeColor','none','basevalue', 0.5,'ShowBaseLine','off')
        plot([-ys ys]+ym,[r r],'color',[0 0 0],'linewidth',3)
        
        cnt = cnt + nChanPerROI(r);
    end
    xlim(xlims);ylim([0.5 2.5])
    plot([0.5 0.5],ylim,'--','color',0.3*ones(3,1),'linewidth',2)
    set(gca,'LineWidth',2,'FontSize',fontSize, 'fontWeight','normal')
    set(gca,'xtick',ticks,'xtickLabel',ticks,'ytick',[])
    set(gca,'box','off')
    
    %
    axes(ha(3)); hold on;
    xlim([0 nROIs]+0.5); ylim(ylims)
    
    cnt = 1;
    for r = 1:nROIs
        roiChans = cnt:nChanPerROI(r)+cnt-1;
        
        ym = mean([M2(roiChans,1)]);
        ys = std([M2(roiChans,1)])/sqrt(nChanPerROI(r)-1);
        
        bar(r,ym,'FaceColor',colors{r},'edgeColor','none','basevalue', 0.5,'ShowBaseLine','off')
        plot([r r],[-ys ys]+ym,'color',[0 0 0],'linewidth',3)
        
        cnt = cnt + nChanPerROI(r);
    end
    plot(xlim,[0.5 0.5],'--','color',0.3*ones(3,1),'linewidth',2)
    set(gca,'LineWidth',2,'FontSize',fontSize,'fontWeight','normal')
    set(gca,'ytick',ticks,'ytickLabel',ticks,'xtick',[])
    
    % legend
    axes('position',[xPos(1) yPos(1) vBarW hBarH]); hold on;
    plot([0.3],[2],'o','color',colors{1},'markersize',15,'markerfacecolor',colors{1})
    plot([0.3],[1],'o','color',colors{2},'markersize',15,'markerfacecolor',colors{2})
    
    xlim([0 1]); ylim([0 3])
    text(0.5,2,'IPS','fontsize',fontSize)
    text(0.5,1,'SPL','fontsize',fontSize)
    set(gca,'visible','off')
    
    %%  plots for ROI level
    
    axes('position', [0.1+vBarW+scatterW+0.02, 0.95, 0.3 0.05])
    text(0.05,0.45,' b ','fontsize',28)
    set(gca,'visible','off')
    
    axes('position', [0.1+vBarW+scatterW+0.08, yPos(2), 2*vBarW vBarH])
    plot([0 3],[0.5 0.5], '--', 'color', 0.3*ones(3,1), 'linewidth',2);hold on;
    xlim([0.5 2.5]); ylim(ylims);
    set(gca,'linewidth',2, 'fontsize', fontSize, 'box','off')
    set(gca,'xtick',[1 2], 'xtickLabel', {'stim', 'resp'})
    set(gca,'ytick',ticks,'ytickLabel',ticks)
    
    subSymbols = {'o','d','s','p','h'};
    
    n       = size(data3.perf(opts.subjects,opts.ROIs,:,:),4);
    RTsMACC  = mean(data4.perf(opts.subjects,opts.ROIs,:,:),4);
    RTsSEACC = std(data4.perf(opts.subjects,opts.ROIs,:,:),0,4)/sqrt(n-1);
    StimMACC = mean(data3.perf(opts.subjects,opts.ROIs,:,:),4);
    StimSEACC = std(data3.perf(opts.subjects,opts.ROIs,:,:),0,4)/sqrt(n-1);
    
    for rr = 1:2
        M =  [];
        M(:,1) = StimMACC(:,rr);
        M(:,2) = RTsMACC(:,rr);
        S = [];
        S(:,1) = StimSEACC(:,rr);
        S(:,2) = RTsSEACC(:,rr);
        
        for ss =1:5
            xpS1 = 1+0.05*randn;
            xpS2 = 2+0.05*randn;
            
            plot([xpS1 xpS1], M(ss,1)+[-S(ss,1) S(ss,1)],'color',0.3*ones(3,1),'linewidth',1)
            plot([xpS2 xpS2], M(ss,2)+[-S(ss,2) S(ss,2)],'color',0.3*ones(3,1),'linewidth',1)
            plot([xpS1 xpS2],M(ss,:),['-' subSymbols{ss}],'color', colors{rr},'markersize',10,'markerfacecolor',colors{rr})
            
        end
    end
    
    axes('position', [0.1+vBarW+scatterW+0.06, yPos(1)-0.03, vBarW*2, hBarH]); hold on;
    for ss=1:5
        plot(0.2*ss,0.5,subSymbols{ss},'color',0.3*ones(3,1),'markersize',10,'markerfacecolor',0.3*ones(3,1))
        text(0.2*ss,0,['S' num2str(ss)],'fontsize',fontSize,'VerticalAlignment','top','horizontalAlignment','center')
    end
    axis off
    
    %%
    cPath = pwd;
    cd(opts.savePath)
    addpath(cPath)
    addpath([cPath '/Plotting/'])
    
    filename = 'Fig3aHGP_ACC';
    plot2svg([filename '.svg'],f)
    eval(['!' inkscapePath ' -z ' filename '.svg --export-pdf=' filename '.pdf'])
    
    cd(cPath)
end
%% renderings
if 0
    
    hem=1;
    chans   = data1.hemChanId == hem ;
    limits = opts.rendLimits-opts.baseLineY;
    opts.limitDw = limits(1);
    opts.limitUp = limits(2);
    opts.absLevel = 0.03;
    opts.renderType = 'SmoothCh';
    opts.hem        = hem_str{hem};
    
    f=figure(2);clf;
    set(f,'Position',[200 200 600 1200]);
    
    ha = tight_subplot(2,1,0.001,0.001,0.001);
    plotSurfaceChanWeights(ha(1), cortex{hem}, chanLocs(chans,:), data1.mBAC(chans)-0.5,opts)
    loc_view(view{hem}(1),view{hem}(2))
    set(gca,'clim',limits);
    h =  title('stim-locked accuracies');
    set(h,'units','normalized','position',[0.5 0.85 0],'fontSize',18)
    
    plotSurfaceChanWeights(ha(2), cortex{hem}, chanLocs(chans,:), data2.mBAC(chans)-0.5,opts)
    loc_view(view{hem}(1),view{hem}(2))
    set(gca,'clim',limits)
    h =  title('RT-locked accuracies');
    set(h,'units','normalized','position',[0.5 0.85 0],'fontSize',18)
    
    filename = [opts.savePath 'Fig3bHGP_acc_Renderings'];
    print(f,'-dtiff',['-r' num2str(opts.resolution)],filename)
    
    %%
    cm = colormap;
    cm = cm(1001:2000,:);
    f(3)=figure(3); clf;
    set(f(3),'position',[-400,100,110,200])
    set(f(3),'colormap',cm)
    h=colorbar;
    set(gca,'visible','off')
    set(h,'position',[0.25 0.1 0.5 0.8])
    set(h,'yTick',[1 1000],'ytickLabel',[50 75],'box','off','fontSize',20)
    set(h,'fontweight','bold')
    set(gcf,'paperSize',[2 3])
    set(gcf,'paperPositionMode','auto')
    filename = [opts.savePath 'Fig3bc_cbar'];
    print(f(3),'-dpdf',filename)
    
end

%% weights

if 1
    t{1} = 0.05:0.1:1;
    t{2} = -0.75:0.1:0.2;
    % second version, including only channels with significant decodign
    % accuracy
    X{1} = squeeze(data1.chModel);
    X{2} = squeeze(data2.chModel);
    
    Y{1} = data1.pBAC;
    Y{2} = data2.pBAC;
    
    yLimits = [-0.06 0.1];
    sigBar      = cell(2,1);
    sigBar{1}   = [0.091 0.091];
    sigBar{2}   = [0.095 0.095];
    
    pThr = 0.005;
    timeTicks   = [0:0.2:1; -0.8:0.2:0.2];
    yTicks      = [-0.05 0 0.05];
    
    f(6) = figure(6); clf;
    figW = 900;
    figH = 300;
    
    set(gcf,'position',[200 200,figW,figH],'PaperPositionMode','auto')
    ha = tight_subplot(1,2);
    
    lMargin = 0.1;
    bMargin = 0.1;
    
    subAxH      = 0.85;
    subAxW      = 0.4;
    betweenColSpace = 0.01;
    
    set(ha(1),'position',[lMargin bMargin subAxW subAxH])
    set(ha(2),'position',[lMargin+subAxW+betweenColSpace bMargin subAxW subAxH])
    
    yRefLims    = [yLimits(1)*0.3 yLimits(2)*0.3];
    
    chIdx{1}   = (data1.ROIid==1) & (data1.hemChanId==1) & (Y{1} < 0.05) & (Y{2} < 0.05);
    chIdx{2}   = (data1.ROIid==2) & (data1.hemChanId==1) & (Y{1} < 0.05) & (Y{2} < 0.05);
    
    for col = 1:2
        axes(ha(col)); cla;
        
        x = cell(2,1);
        x{1} = X{col}(chIdx{1},:);
        x{2} = X{col}(chIdx{2},:);
        
        % plot traces
        hh=plotNTraces(x,t{col},'rb','none',[],'mean',yLimits); hold on;
        yy=get(gca,'children');
        set(yy(9),'YData',[yRefLims],'color',0.3*ones(3,1))
        set(yy(10),'color',0.3*ones(3,1))
        
        % plot sig bar IPS
        h = ttest(x{1},0,pThr);
        sigBins = t{col}(h==1);
        for ii = 1:numel(sigBins)
            plot([-0.05 0.05]+sigBins(ii),sigBar{1},'linewidth',2,'color',colors{1})
            plot(sigBins(ii),sigBar{1}(1),'*','linewidth',2,'color',colors{1})
        end
        
        % plot sig bar SPL
        h = ttest(x{2},0,pThr);
        sigBins = t{col}(h==1);
        for ii = 1:numel(sigBins)
            plot([-0.05 0.05]+sigBins(ii),sigBar{2},'linewidth',2,'color',colors{2})
            plot(sigBins(ii),sigBar{2}(1),'*','linewidth',2,'color',colors{2})
        end
        
        
        set(gca,'fontsize',18,'fontWeight','normal')
        set(gca,'ytick',yTicks)
        set(gca,'yticklabel',{num2str(yTicks(1)),'0',num2str(yTicks(3))})
        set(gca,'xtick', timeTicks(col,:))
        
        if (col==1) % left upper plot
            xx=legend([hh.h1.mainLine,hh.h2.mainLine],'IPS','SPL');
            set(xx,'box','off','location','northwest')
            set(gca,'XtickLabel',{'stim','','0.4','','0.8',''})
            xlim([-0.1 1.02])
            set(yy(10),'Xdata',[-0.1 1.02])
        end
        
        if (col==2) % lower right plot
            set(gca,'YAXisLocation','right')
            set(gca,'XtickLabel',{'-0.8','','-0.4','','resp',''})
            xlim([-0.9 0.22])
            set(yy(10),'Xdata',[-0.9 0.22])
        end
        
    end
    
    axes('position', [0 bMargin 0.06 0.85])
    text(0.3,0.5,' Decoder Weights (au) ','fontsize',20,'rotation',90, ...
        'VerticalAlignment','middle','horizontalAlignment','center')
    set(gca,'visible','off')
    
    cPath = pwd;
    cd(SupPlotPath)
    addpath(cPath)
    addpath([cPath '/Plotting/'])
    
    filename = 'sFig9_chDec-Weights-HGP';
    plot2svg([filename '.svg'],gcf)
    eval(['!' inkscapePath ' -z ' filename '.svg --export-pdf=' filename '.pdf'])
    cd(cPath)
end




