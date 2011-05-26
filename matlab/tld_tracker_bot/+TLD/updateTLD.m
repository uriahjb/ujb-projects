% TLD is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TLD.  If not, see <http://www.gnu.org/licenses/>.

function [tld, opt] = updateTLD(IP, frameNumber, tld, opt)
    % And another hack ... write new current file to dir
    imwrite(imread(IP), [opt.source.input num2str(frameNumber,'%05d') '.png']);    
    % Update state of dir
    tld.source.files = img_dir(tld.source.input);
    
    %%
    
    tld = tldProcessFrame(tld,frameNumber); % process frame i
    tldDisplay(1,tld,frameNumber); % display results on frame i
    
    if tld.plot.save == 1
        img = getframe;
        imwrite(img.cdata,[tld.output num2str(frameNumber,'%05d') '.png']);
    end
end
