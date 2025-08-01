function results = testTask(tags)
% Run unit tests

arguments
    tags string {mustBeText} = "";
end

import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.Verbosity;
import matlab.unittest.plugins.XMLPlugin;
import matlab.unittest.parameters.Parameter;

projObj = currentProject;

% Get list of example scripts in path
exName = {dir(fullfile(projObj.RootFolder,'toolbox/examples','**/*.m')).name}';
exName = exName(isFileOnPath(exName));
exName = filterOutTests(exName);
exParam = Parameter.fromData('exName',exName);

suite = TestSuite.fromProject(projObj,'ExternalParameters',exParam);
if strlength(tags)>0
    suite = suite.selectIf("Tag",tags);
else
    disp('No tag was passed as input. All test cases will be executed.');
end

if isempty(suite)
    warning('No tests were found with tag(s) "%s" and none will be executed.',strjoin(tags,', '));
end

runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);
runner.addPlugin(XMLPlugin.producingJUnitFormat(fullfile(projObj.RootFolder,'results.xml')));

results = runner.run(suite);
results.assertSuccess;

end

function onPath = isFileOnPath(filename)
onPath = boolean(zeros(1,length(filename)));
for ii = 1:length(filename)
    onPath(ii) = exist(filename{ii},"file")>0;
end
end

function testcases = filterOutTests(testcases)

% Example doesn't work without real EEG data
testcases(ismember(testcases,{'demo_mu_rhythm_phase_triggering.m'})) = [];

if ~isMATLABReleaseOlderThan("R2025a")
    % Issue when reading sample rate from osc_alpha_ip. Diff is not constant
    testcases(ismember(testcases,{'demo_phase_prediction_error_simple.m'})) = [];
end

end