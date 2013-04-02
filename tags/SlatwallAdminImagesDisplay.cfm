<cfif thisTag.executionMode is "start">
	<cfparam name="attributes.hibachiScope" type="any" default="#request.context.fw.getHibachiScope()#" />
	<cfparam name="attributes.object" type="any" />
	
	<div class="tab-pane" id="tabImages">
		<cfoutput>
			<ul class="thumbnails">
  				<cfloop array="#attributes.object.getImages()#" index="image">
					<li class="span3">
	    				<div class="thumbnail">
	    					<a href="?slatAction=admin:entity.detailImage">
	      						#image.getImage(width=210, height=210)#
							</a>
							<cfif !isNull(image.getImageName()) && len(image.getImageName())>
	      						<h3>#image.getImageName()#</h3>
							</cfif>
							<cfif !isNull(image.getImageDescription()) && len(image.getImageDescription())>
	      						#image.getImageDescription()#
							</cfif>
							<div class="small em image-caption" style="overflow:hidden;">#image.getImagePath()#</div>
	    				</div>
	  				</li>
				</cfloop>
			</ul>
			<cf_HibachiActionCaller action="admin:entity.createImage" querystring="#attributes.object.getPrimaryIDPropertyName()#=#attributes.object.getPrimaryIDValue()#&objectName=#attributes.object.getClassName()#&redirectAction=#request.context.slatAction#" modal="true" class="btn" icon="plus" />
		</cfoutput>
	</div>
</cfif>